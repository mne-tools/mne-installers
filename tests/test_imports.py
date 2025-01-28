import platform


def check_min_version(package, min_version):
    """Check a minimum version."""
    from packaging.version import parse

    assert parse(package.__version__) >= parse(min_version), (
        f"{package}: got {package.__version__} wanted {min_version}"
    )


import mne

check_min_version(mne, "1.4")
import mne_bids
import mne_bids_pipeline

check_min_version(mne_bids_pipeline, "1.2")
import mne_connectivity

import mne_faster
import mne_nirs
import mne_qt_browser

check_min_version(mne_qt_browser, "0.5.0")
import mne_features
import mne_rsa
import mne_microstates
import mne_ari
import mne_kit_gui
import mne_lsl
import mne_icalabel
import autoreject
import wfdb
import meegkit
import eeg_positions
import pyriemann
import pyprep
import pycrostates
import darkdetect
import qdarkstyle
import numba
import openpyxl
import xlrd
import pingouin
import pactools
import tensorpac
import emd
import neurodsp

# import bycycle  # TODO
import fooof
import openneuro

import sleepecg
import yasa
import neo
import neurokit2
import questionary
import matplotlib.pyplot
import seaborn
import plotly
import pqdm
import pyvistaqt
import vtk
import PySide6.QtCore

import matplotlib.pyplot as plt

backend = plt.get_backend()
assert backend.lower() == "qtagg", backend

check_min_version(pyvistaqt, "0.11.0")

if platform.system() == "Darwin":
    import Foundation  # pyobjc
