print("Running imports")
import faulthandler

faulthandler.enable()

import os
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
import pyvista

import mne

this_path = Path(__file__).parent

# Matplotlib
print("Running matplotlib tests")
fig, _ = plt.subplots()
want = "QTAgg"
assert want in repr(fig.canvas), repr(fig.canvas)
plt.close("all")

# pyvistaqt
if os.getenv("SKIP_PYVISTAQT_TESTS", "").lower() in ("1", "true"):
    print("Skipping PyVistaQt tests")
else:
    print("Running pyvistaqt tests")
    fname = this_path / "test.png"
    mne.viz.set_3d_backend("pyvista")
    fig = mne.viz.create_3d_figure((400, 400), scene=False, show=True)
    fig._process_events()
    fig._process_events()
    plotter = fig.figure.plotter
    plotter.add_orientation_widget(pyvista.Cube())  # Old test without color='b'
    plotter.add_mesh(pyvista.Cube(), render=True)
    if fname.is_file():
        os.remove(fname)
    assert not fname.is_file()
    fig._process_events()
    plotter.screenshot(fname)
    assert fname.is_file()
    os.remove(fname)
    assert "BackgroundPlotter" in repr(plotter), repr(plotter)
    mne.viz.close_3d_figure(fig)

# mne-qt-browser
print("Running mne-qt-browser tests")
mne.viz.set_browser_backend("qt")
raw = mne.io.RawArray(np.zeros((1, 1000)), mne.create_info(1, 1000.0, "eeg"))
fig = raw.plot()
fig.close()
assert "MNEQtBrowser" in repr(fig), repr(fig)
