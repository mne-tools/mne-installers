import os
from pyface.api import GUI
import mne_kit_gui

if os.getenv("SKIP_MNE_KIT_GUI_TESTS", "").lower() in ("1", "true"):
    print("Skipping MNE-KIT-GUI tests")
    exit()
print("Running MNE-KIT-GUI tests", end="")
os.environ["_MNE_GUI_TESTING_MODE"] = "true"
gui = GUI()
gui.process_events()
ui, frame = mne_kit_gui.kit2fiff()
assert not frame.model.can_save
ui.dispose()
print(" done")
