# Create one nbclient and reuse it
import os
from mne.utils import Bunch
import nbformat
from jupyter_client import AsyncKernelManager
from nbclient import NotebookClient
from ipywidgets import Button  # noqa

if os.getenv("SKIP_NOTEBOOK_TESTS", "").lower() in ("1", "true"):
    print("Skipping notebook tests")
    exit(0)

print("Running notebook tests")

km = AsyncKernelManager(config=None)
nb = nbformat.reads(
    """
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata":{},
   "outputs": [],
   "source":[]
  }
 ],
 "metadata": {
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version":3},
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.7.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}""",
    as_version=4,
)
_nbclient = NotebookClient(nb, km=km)
_nbclient.reset_execution_trackers()
code = """\
# matplotlib
%matplotlib inline
import matplotlib.pyplot as plt
fig, ax = plt.subplots()
assert 'CanvasAgg ' in repr(fig.canvas), repr(fig.canvas)

import mne
mne.viz.set_3d_backend('notebook')
fig = mne.viz.create_3d_figure((400, 400), show=True)
assert '.Plotter ' in repr(fig.plotter), repr(fig.plotter)
"""
with _nbclient.setup_kernel():
    assert _nbclient.kc is not None
    cell = Bunch(cell_type="code", metadata={}, source=code)
    _nbclient.execute_cell(cell, 0, execution_count=0)
    _nbclient.set_widgets_metadata()
_nbclient._cleanup_kernel()
