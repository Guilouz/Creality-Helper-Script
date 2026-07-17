import importlib.util
import pathlib
import unittest


MODULE_PATH = (
    pathlib.Path(__file__).parents[1]
    / "files"
    / "high-resolution-bed-mesh"
    / "prtouch_extended_points.py"
)
SPEC = importlib.util.spec_from_file_location(
    "prtouch_extended_points", MODULE_PATH
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class FakeGCode:
    def __init__(self):
        self.commands = {}

    def register_command(self, name, callback, desc=None):
        self.commands[name] = callback


class FakePRTouch:
    def __init__(self, count=36):
        self.tri_min_hold_ALL = [[6000, 10000] for _ in range(count)]
        self.tri_max_hold_ALL = [[13000, 60000] for _ in range(count)]


class FakePrinter:
    def __init__(self, prtouch):
        self.objects = {"gcode": FakeGCode(), "prtouch_v2": prtouch}
        self.handlers = {}

    def lookup_object(self, name, default=None):
        return self.objects.get(name, default)

    def register_event_handler(self, event, callback):
        self.handlers[event] = callback

    def config_error(self, message):
        return RuntimeError(message)


class FakeConfig:
    def __init__(self, printer, max_points=100):
        self.printer = printer
        self.max_points = max_points

    def get_printer(self):
        return self.printer

    def getint(self, name, default, minval=None, maxval=None):
        return self.max_points


class PRTouchExtendedPointsTest(unittest.TestCase):
    def test_extends_factory_tables_to_ten_by_ten(self):
        prtouch = FakePRTouch()
        printer = FakePrinter(prtouch)
        extension = MODULE.PRTouchExtendedPoints(FakeConfig(printer))

        printer.handlers["klippy:connect"]()

        self.assertEqual(100, len(prtouch.tri_min_hold_ALL))
        self.assertEqual(100, len(prtouch.tri_max_hold_ALL))
        self.assertEqual([6000, 10000], prtouch.tri_min_hold_ALL[-1])
        self.assertEqual([13000, 60000], prtouch.tri_max_hold_ALL[-1])
        self.assertIsNot(
            prtouch.tri_min_hold_ALL[-1], prtouch.tri_min_hold_ALL[-2]
        )
        self.assertEqual(100, extension.get_status(0)["requested_points"])

    def test_does_not_shrink_newer_firmware_tables(self):
        prtouch = FakePRTouch(count=121)
        printer = FakePrinter(prtouch)
        MODULE.PRTouchExtendedPoints(FakeConfig(printer))._handle_connect()

        self.assertEqual(121, len(prtouch.tri_min_hold_ALL))
        self.assertEqual(121, len(prtouch.tri_max_hold_ALL))

    def test_rejects_incompatible_prtouch_backend(self):
        printer = FakePrinter(object())
        extension = MODULE.PRTouchExtendedPoints(FakeConfig(printer))

        with self.assertRaisesRegex(
            RuntimeError, "compatible PRTouch threshold tables"
        ):
            extension._handle_connect()

    def test_rejects_mismatched_threshold_tables(self):
        prtouch = FakePRTouch()
        prtouch.tri_max_hold_ALL.pop()
        printer = FakePrinter(prtouch)
        extension = MODULE.PRTouchExtendedPoints(FakeConfig(printer))

        with self.assertRaisesRegex(RuntimeError, "sizes do not match"):
            extension._handle_connect()


if __name__ == "__main__":
    unittest.main()
