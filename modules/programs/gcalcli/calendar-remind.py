#!/usr/bin/env python3
import html
import html.parser
import subprocess
import sys
from collections import namedtuple
from datetime import datetime, timedelta

from dateutil.tz import tzlocal

from gcalcli.gcal import GoogleCalendarInterface

CalName = namedtuple("CalName", ["name", "color"])


class HTMLToText(html.parser.HTMLParser):
    def __init__(self):
        super().__init__()
        self.result = []

    def handle_data(self, data):
        self.result.append(data)

    def handle_starttag(self, tag, attrs):
        if tag == "br":
            self.result.append("\n")

    def handle_endtag(self, tag):
        if tag in ("p", "div"):
            self.result.append("\n")


def html_to_text(raw):
    if not raw:
        return ""
    parser = HTMLToText()
    parser.feed(html.unescape(raw))
    return "".join(parser.result).strip()


def main():
    if len(sys.argv) < 2:
        print(
            "Usage: calendar-remind <calendar> [calendar...]",
            file=sys.stderr,
        )
        sys.exit(1)

    cal_names = [CalName(name=c, color="default") for c in sys.argv[1:]]

    gcal = GoogleCalendarInterface(
        cal_names=cal_names,
        refresh_cache=False,
        use_cache=True,
        ignore_calendars=[],
        config_folder=None,
    )

    now = datetime.now(tzlocal())
    end = now + timedelta(minutes=5)
    events = gcal._search_for_events(now, end, None)

    for event in events:
        if event["s"] < now:
            continue

        if gcal._DeclinedEvent(event):
            continue

        if "dateTime" not in event.get("start", {}):
            continue

        title = event.get("summary", "(No title)").strip()
        start_time = event["s"].strftime("%H:%M")
        description = html_to_text(event.get("description", ""))

        conference_uri = ""
        for ep in event.get("conferenceData", {}).get("entryPoints", []):
            if ep.get("entryPointType") == "video":
                conference_uri = ep.get("uri", "")
                break

        body = f"Starts at {start_time}"
        if description:
            body += f"\n\n{description}"

        if conference_uri:
            subprocess.Popen(
                [
                    "bash", "-c",
                    'action=$(notify-send -a Calendar -i appointment-soon '
                    '-u critical -A "join=Join Meeting" '
                    '-- "$1" "$2") && '
                    '[ "$action" = "join" ] && '
                    'exec xdg-open "$3"',
                    "--", title, body, conference_uri,
                ],
                start_new_session=True,
            )
        else:
            subprocess.Popen(
                [
                    "notify-send",
                    "-a", "Calendar",
                    "-i", "appointment-soon",
                    "-u", "critical",
                    "--", title, body,
                ],
                start_new_session=True,
            )


if __name__ == "__main__":
    main()
