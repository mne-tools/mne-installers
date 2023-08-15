import platform


def check_min_version(package, min_version):
    """Check a minimum version."""
    from packaging.version import parse

    assert parse(package.__version__) >= parse(
        min_version
    ), f"{package}: got {package.__version__} wanted {min_version}"


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
import mne_realtime
import mne_features
import mne_rsa
import mne_microstates
import mne_ari
import mne_kit_gui

if platform.system() != "Windows":
    import mne_icalabel
import autoreject
import pyprep
import pycrostates
import darkdetect
import qdarkstyle
import numba
import openpyxl
import xlrd
import pingouin
import pycircstat
import pactools
import tensorpac
import emd
import neurodsp
import bycycle
import fooof
import openneuro
import sleepecg
import yasa
import neurokit2
import questionary
import matplotlib
import seaborn
import plotly
import pqdm
