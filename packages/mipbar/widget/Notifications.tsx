import Gio from "gi://Gio"
import GLib from "gi://GLib"
import Gtk from "gi://Gtk?version=4.0"
import Pango from "gi://Pango"
import { createState, With } from "ags"
import { execAsync } from "ags/process"
import {
  isAbsolutePath,
  isScreenshot,
  plainText,
  relativeTime,
  screenshotPath,
  themedIcon,
} from "../state/notification"
import {
  clearNotifications,
  lastCapturePath,
  notifications,
  SHOT_ANNOTATE,
  SHOT_REVEAL,
} from "../state/notifications"

export default function Notifications() {
  const [now, setNow] = createState(Date.now())
  let popoverRef: Gtk.Popover | null = null

  return (
    <menubutton class="StatusIcon Notifications" tooltipText="Notificaties">
      <label label="󰂚" />
      <popover
        $={(self: Gtk.Popover) => {
          popoverRef = self
          self.connect("notify::visible", () => {
            if (self.get_visible()) setNow(Date.now())
          })
        }}
      >
        <box orientation={Gtk.Orientation.VERTICAL} class="NotificationsPopover">
          <box class="NotificationPopoverHeader">
            <label label="MELDINGEN" hexpand halign={Gtk.Align.START} />
            <button
              class="NotificationClear"
              tooltipText="Alles wissen"
              visible={notifications((list) => list.length > 0)}
              onClicked={() => clearNotifications()}
            >
              <label label="✕" />
            </button>
          </box>

          <With value={notifications}>
            {(list) => {
              if (list.length === 0) {
                return (
                  <label
                    class="NotificationEmpty"
                    label="Geen recente notificaties"
                    halign={Gtk.Align.START}
                  />
                )
              }

              return (
                <Gtk.ScrolledWindow
                  $={(self: Gtk.ScrolledWindow) => {
                    self.set_policy(
                      Gtk.PolicyType.NEVER,
                      Gtk.PolicyType.AUTOMATIC,
                    )
                    self.set_propagate_natural_height(true)
                    self.set_max_content_height(420)
                    self.set_min_content_height(80)
                  }}
                >
                  <box
                    orientation={Gtk.Orientation.VERTICAL}
                    class="NotificationList"
                    spacing={6}
                  >
                    {list.map((n) => {
                      const reveal = () => {
                        popoverRef?.popdown()
                        execAsync([
                          SHOT_REVEAL,
                          screenshotPath(n, lastCapturePath()),
                        ]).catch(() => {})
                      }

                      const annotate = () => {
                        popoverRef?.popdown()
                        execAsync([
                          SHOT_ANNOTATE,
                          screenshotPath(n, lastCapturePath()),
                        ]).catch(() => {})
                      }

                      const icon = themedIcon(n)
                      const image =
                        isAbsolutePath(n.image) &&
                        GLib.file_test(n.image, GLib.FileTest.EXISTS) ? (
                          <Gtk.Picture
                            class="NotificationImage"
                            hexpand
                            canShrink
                            contentFit={Gtk.ContentFit.CONTAIN}
                            heightRequest={140}
                            $={(self: Gtk.Picture) =>
                              self.set_file(Gio.File.new_for_path(n.image))
                            }
                          />
                        ) : null

                      const content = (
                        <box
                          orientation={Gtk.Orientation.VERTICAL}
                          class="NotificationBody"
                        >
                          <box class="NotificationHead">
                            {icon !== null && (
                              <image
                                class="NotificationAppIcon"
                                iconName={icon}
                              />
                            )}
                            <label
                              class="NotificationApp"
                              label={n.appName || "Melding"}
                              hexpand
                              halign={Gtk.Align.START}
                              ellipsize={Pango.EllipsizeMode.END}
                            />
                            <label
                              class="NotificationTime"
                              label={now((t) => relativeTime(n.receivedAt, t))}
                              halign={Gtk.Align.END}
                            />
                          </box>
                          <label
                            class="NotificationSummary"
                            label={n.summary}
                            wrap
                            xalign={0}
                            halign={Gtk.Align.START}
                          />
                          {n.body !== "" && (
                            <label
                              class="NotificationText"
                              label={plainText(n.body)}
                              wrap
                              xalign={0}
                              halign={Gtk.Align.START}
                            />
                          )}
                          {image}
                        </box>
                      )

                      if (!isScreenshot(n)) {
                        return <box class="NotificationCard">{content}</box>
                      }

                      return (
                        <box
                          orientation={Gtk.Orientation.VERTICAL}
                          class="NotificationCard"
                        >
                          <button
                            class="NotificationButton"
                            hexpand
                            onClicked={reveal}
                          >
                            {content}
                          </button>
                          <box class="NotificationActions" spacing={8}>
                            <button
                              class="ActionSmall"
                              hexpand
                              onClicked={reveal}
                            >
                              <label label="Tonen" />
                            </button>
                            <button
                              class="ActionSmall"
                              hexpand
                              onClicked={annotate}
                            >
                              <label label="Bewerken" />
                            </button>
                          </box>
                        </box>
                      )
                    })}
                  </box>
                </Gtk.ScrolledWindow>
              )
            }}
          </With>
        </box>
      </popover>
    </menubutton>
  )
}
