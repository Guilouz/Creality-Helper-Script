import logging


class PRTouchExtendedPoints:
    """Extend the K1 Max PRTouch v2 fixed-size threshold tables."""

    def __init__(self, config):
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object("gcode")
        self.max_points = config.getint(
            "max_points", 100, minval=36, maxval=144
        )
        self.min_threshold_count = 0
        self.max_threshold_count = 0
        self.printer.register_event_handler(
            "klippy:connect", self._handle_connect
        )
        self.gcode.register_command(
            "PRTOUCH_EXTENDED_POINTS_STATUS",
            self.cmd_PRTOUCH_EXTENDED_POINTS_STATUS,
            desc="Report extended PRTouch threshold table sizes",
        )

    def _handle_connect(self):
        prtouch = self.printer.lookup_object("prtouch_v2", None)
        if prtouch is None:
            raise self.printer.config_error(
                "prtouch_extended_points: [prtouch_v2] was not found"
            )

        min_table = getattr(prtouch, "tri_min_hold_ALL", None)
        max_table = getattr(prtouch, "tri_max_hold_ALL", None)
        if not min_table or not max_table:
            raise self.printer.config_error(
                "prtouch_extended_points: compatible PRTouch threshold "
                "tables were not found"
            )
        if len(min_table) != len(max_table):
            raise self.printer.config_error(
                "prtouch_extended_points: PRTouch threshold table sizes "
                "do not match"
            )

        # Creality configures the same threshold pair for all 36 factory
        # positions. New positions inherit the final configured pair. No
        # probing, homing, or motion implementation is replaced here.
        while len(min_table) < self.max_points:
            min_table.append(list(min_table[-1]))
        while len(max_table) < self.max_points:
            max_table.append(list(max_table[-1]))

        self.min_threshold_count = len(min_table)
        self.max_threshold_count = len(max_table)
        logging.info(
            "prtouch_extended_points: threshold tables available: %d/%d",
            self.min_threshold_count,
            self.max_threshold_count,
        )

    def cmd_PRTOUCH_EXTENDED_POINTS_STATUS(self, gcmd):
        gcmd.respond_info(
            "PRTouch threshold entries: min=%d, max=%d, requested=%d"
            % (
                self.min_threshold_count,
                self.max_threshold_count,
                self.max_points,
            )
        )

    def get_status(self, eventtime):
        return {
            "requested_points": self.max_points,
            "min_threshold_count": self.min_threshold_count,
            "max_threshold_count": self.max_threshold_count,
        }


def load_config(config):
    return PRTouchExtendedPoints(config)
