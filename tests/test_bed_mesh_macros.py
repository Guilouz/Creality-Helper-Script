import pathlib
import unittest
from types import SimpleNamespace

try:
    from jinja2 import Environment, StrictUndefined
except ImportError:  # Klipper provides Jinja2; allow stdlib-only test runs.
    Environment = None


ROOT = pathlib.Path(__file__).parents[1]


def macro_body(path, section):
    lines = path.read_text().splitlines()
    section_start = lines.index(section)
    gcode_start = next(
        index
        for index in range(section_start + 1, len(lines))
        if lines[index].strip() == "gcode:"
    )
    body = []
    for line in lines[gcode_start + 1 :]:
        if line.startswith("["):
            break
        body.append(line[2:] if line.startswith("  ") else line)
    return "\n".join(body)


@unittest.skipIf(Environment is None, "Jinja2 is not installed")
class BedMeshMacroTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.messages = []
        cls.environment = Environment(
            undefined=StrictUndefined,
            variable_start_string="{",
            variable_end_string="}",
        )
        cls.environment.globals.update(
            action_raise_error=cls.raise_macro_error,
            action_respond_info=cls.record_message,
        )
        cls.bed_leveling = cls.environment.from_string(
            macro_body(
                ROOT / "files" / "macros" / "useful-macros.cfg",
                "[gcode_macro BED_LEVELING]",
            )
        )
        cls.kamp = cls.environment.from_string(
            macro_body(
                ROOT / "files" / "kamp" / "Adaptive_Meshing.cfg",
                "[gcode_macro BED_MESH_CALIBRATE]",
            )
        )

    @staticmethod
    def raise_macro_error(message):
        raise RuntimeError(message)

    @classmethod
    def record_message(cls, message):
        cls.messages.append(message)
        return ""

    def setUp(self):
        self.messages.clear()
        self.settings = {
            "bed_mesh": SimpleNamespace(
                mesh_min=[5, 5], mesh_max=[295, 295], probe_count=[6, 6]
            ),
            "prtouch_v2": SimpleNamespace(pr_version=2),
            "prtouch_extended_points": SimpleNamespace(max_points=100),
        }
        self.toolhead = SimpleNamespace(
            homed_axes="xyz",
            axis_maximum=SimpleNamespace(x=300, y=300),
        )

    def printer(self, settings=None):
        return SimpleNamespace(
            configfile=SimpleNamespace(settings=settings or self.settings),
            toolhead=self.toolhead,
        )

    def test_square_grids_and_k1_max_spacing(self):
        for points, spacing in ((6, "58.00"), (9, "36.25"), (10, "32.22")):
            with self.subTest(points=points):
                self.messages.clear()
                output = self.bed_leveling.render(
                    printer=self.printer(), params={"POINTS": str(points)}
                )
                self.assertIn(
                    "PROBE_COUNT=%d,%d" % (points, points), output
                )
                self.assertIn(spacing, self.messages[-1])

    def test_high_resolution_fails_without_extension(self):
        settings = dict(self.settings)
        settings.pop("prtouch_extended_points")

        with self.assertRaisesRegex(
            RuntimeError, "install High Resolution Bed Mesh"
        ):
            self.bed_leveling.render(
                printer=self.printer(settings), params={"POINTS": "9"}
            )

    def test_high_resolution_fails_on_prtouch_v1(self):
        settings = dict(self.settings)
        settings["prtouch_v2"] = SimpleNamespace(pr_version=1)

        with self.assertRaisesRegex(RuntimeError, "only on PRTouch v2"):
            self.bed_leveling.render(
                printer=self.printer(settings), params={"POINTS": "9"}
            )

    def test_invalid_point_parameters_fail(self):
        cases = (
            ({"POINTS": "2"}, "at least 3"),
            ({"POINTS": "11"}, "must not exceed 10"),
            (
                {"POINTS": "9", "PROBE_COUNT": "9,9"},
                "not both",
            ),
        )
        for params, message in cases:
            with self.subTest(params=params):
                with self.assertRaisesRegex(RuntimeError, message):
                    self.bed_leveling.render(
                        printer=self.printer(), params=params
                    )

    def test_kamp_receives_explicit_full_bed_request(self):
        settings = dict(self.settings)
        settings["gcode_macro _kamp_settings"] = object()

        output = self.bed_leveling.render(
            printer=self.printer(settings), params={"POINTS": "10"}
        )

        self.assertIn(
            "BED_MESH_CALIBRATE FULL_BED=1 PROBE_COUNT=10,10", output
        )

    def test_kamp_keeps_full_bounds_for_supported_grids(self):
        printer = {
            "exclude_object": SimpleNamespace(objects=[]),
            "configfile": SimpleNamespace(settings=self.settings),
            "gcode_macro _KAMP_Settings": SimpleNamespace(
                verbose_enable=1, mesh_margin=0, fuzz_amount=0
            ),
        }
        for points in (6, 9, 10):
            with self.subTest(points=points):
                output = self.kamp.render(
                    printer=printer,
                    params={
                        "FULL_BED": "1",
                        "PROBE_COUNT": "%d,%d" % (points, points),
                    },
                )
                algorithm = "bicubic" if points > 6 else "lagrange"
                expected = (
                    "_BED_MESH_CALIBRATE mesh_min=5,5 "
                    "mesh_max=295,295 ALGORITHM=%s PROBE_COUNT=%d,%d"
                    % (algorithm, points, points)
                )
                self.assertIn(expected, output)


if __name__ == "__main__":
    unittest.main()
