import logging

logging.info('Running imports')
import os
import sys
from pathlib import Path

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import pyvista

import mne

this_path = Path(__file__).parent

# Matplotlib
logging.info('Running matplotlib tests')
fig, _ = plt.subplots()
want = 'QTAgg'
assert want in repr(fig.canvas), repr(fig.canvas)
plt.close('all')

# pyvistaqt
logging.info('Running pyvistaqt tests')
fname = this_path / 'test.png'
mne.viz.set_3d_backend('pyvista')
fig = mne.viz.create_3d_figure((400, 400), scene=False)
plotter = fig.figure.plotter
plotter.add_orientation_widget(pyvista.Cube())  # Old test without color='b'
plotter.add_mesh(pyvista.Cube())
if fname.is_file():
    os.remove(fname)
assert not fname.is_file()
fig._process_events()
plotter.screenshot(fname)
assert fname.is_file()
os.remove(fname)
mne.viz.close_3d_figure(fig)
assert '.BackgroundPlotter' in repr(plotter), repr(plotter)

# mne-qt-browser
logging.info('Running mne-qt-browser tests')
mne.viz.set_browser_backend('qt')
raw = mne.io.RawArray(np.zeros((1, 1000)), mne.create_info(1, 1000., 'eeg'))
fig = raw.plot()
fig.close()
assert 'MNEQtBrowser' in repr(fig), repr(fig)

# mne-kit-gui
logging.info('Running mne-kit-gui tests')
from pyface.api import GUI  # noqa
import mne_kit_gui  # noqa
os.environ['_MNE_GUI_TESTING_MODE'] = 'true'
gui = GUI()
gui.process_events()
ui, frame = mne_kit_gui.kit2fiff()
assert not frame.model.can_save
ui.dispose()
