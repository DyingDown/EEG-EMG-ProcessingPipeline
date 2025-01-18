# User Manual

中文版本手册在这里：https://dyingdown.github.io/2025/01/18/EEG-EMG-ProcessingPipeline%E5%B7%A5%E5%85%B7%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E/

## Data Description

This tool is designed for processing data in `.txt` format, where EEG and EMG data are mixed. The experiment involves only two events, **a** and **b**, with the data formatted as follows:

```
# MIX|None|0+True+Tibialis Anterior+1000|1+True+Peroneus Longus+1000|2+True+Medial Gastrocnemius+1000|3+True+Lateral Gastrocnemius+1000|4+True+Rectus Femoris+1000|5+True+Vastus Medialis+1000|6+True+Biceps Femoris Long Head+1000|7+True+Semitendinosus+1000|8+False+Tibialis Anterior+1000|9+False+Peroneus Longus+1000|10+False+Medial Gastrocnemius+1000|11+False+Lateral Gastrocnemius+1000|12+False+EMG13+1000|13+False+EMG14+1000|14+False+EMG15+1000|15+False+EMG16+1000|0+True+P4+80|1+True+CP2+80|2+True+FC5+80|3+True+C3+80|4+True+P3+80|5+True+C2+80|6+True+FC6+80|7+True+C4+80|8+True+CP6+80|9+True+F3+80|10+True+FC2+80|11+True+FC1+80|12+True+F4+80|13+True+CP5+80|14+True+C1+80|15+True+CP1+80
# 13425+24732+39459+51551+66531+77703+93361+104448
0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00
...
```

The second row contains marker information.

To enable automatic data discovery, data must be stored in the following format:

```
├─code_locs
├─subj0
│  └─original
│       ├─b.txt
│  		└─a.txt
└─subj1
    └─original
```

Each `subj0` and `subj1` represents a data source, and raw data files must be directly placed in the `original` folder.

## Installation Requirements

- **Software**: Use MATLAB for data analysis.
- **Required Tool**: Install **EEGLAB** beforehand.

## Configuration

1. **`dataBaseFolder`**: Specifies the root directory storing raw data files. The program searches this directory for `.txt` files containing EEG and EMG data.

2. **`avgDatasFolder`**: Specifies the directory to store processed data, especially results for average calculations. Cleaned or processed data will be saved here.

3. `startPoint`: Defines the method for event start-point determination.

   - **`isPeak`** (boolean): Indicates whether the marker position corresponds to a signal's peak (midpoint). If `true`, the event marker aligns with the middle peak.

4. **`Fs`**: Sampling rate, determining the number of data points collected per second, primarily for preprocessing.

5. `artifacts`

   : Defines thresholds for artifact detection to remove invalid signals from the data. Each artifact type has:

   - **`lower_limit`**: The minimum value for filtering signal data.
   - **`upper_limit`**: The maximum value for filtering signal data.
   - Artifact types:
     - **Brain**: EEG artifacts.
     - **Muscle**: EMG artifacts.
     - **Eye**, **Heart**, **Line Noise**, **Channel Noise**, **Other**: Artifacts related to eyes, heartbeats, electrical noise, channel noise, and others.

## Workflow Overview

Run the `main.m` file.

<img src="https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172136204.png" alt="img" style="zoom:67%;" />

There are five main functions:

1. **Point Info Man Corr**: Allows manual correction or completion of marker data by visualizing waveforms, with automatic filtering and trimming.
2. **EEGLAB Preprocessing**: Imports data into EEGLAB for bad-channel interpolation and artifact removal.
3. **Calculate Data**: Computes EEG and EMG correlations.
4. **Plot Data**: Plots coherence data.
5. **Plot Coh Avg**: Computes and plots the average coherence across datasets.

### Point Info Man Corr

Clicking this button opens the following graphical interface:

<img src="https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172304731.png" style="zoom: 67%;" />

It displays the graph of the first data point it finds, as shown below:

<img src="https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172309990.png" style="zoom:67%;" />

#### Input Window Explanation:

- **TL_a**: Duration of Event A in milliseconds (ms).
- **TL_b**: Duration of Event B in milliseconds.
- **Start Points**: Major point information in milliseconds, with values separated by commas.
- **Banned EMG List**: Specifies EMG channels to hide. Enter numbers (representing the y-axis order of EMG channels) separated by commas.
- **Banned EEG List**: Specifies EEG channels to hide. Similar to above, input the indices of EEG channels to exclude.

#### Button Explanation:

- **Save & Update figure**: Saves the marked point information and updates the graph.
- **Update Banned Channel**: Updates the graph after modifying the Banned EEG/EMG List.
- **View Cutted Figure**: Displays the appearance of trimmed data (removing parts irrelevant to event information).
- **Close**: Closes the current data file without saving any information. Ensure you save with "Save & Update figure" before closing to retain changes. Closing without saving allows the data to remain accessible when reopened later.
- **Mark Finish Permanently**: Marks the current dataset as completed, preventing future display.
- **Discard this file**: Discards datasets that are too disorganized to use.

------

### **EEGLAB Preprocessing**

#### Importing Data

Clicking the `EEGLAB Preprocessing` button in the smaller window automatically locates trimmed datasets and imports them into EEGLAB. The imported data is stored in the `subjx/set/beforeInterp` directory.

#### Bad Channel Interpolation

The tool performs bad channel interpolation as the first step in EEGLAB.

Initially, it displays the waveform of the current dataset:

<img src="https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172321558.png" style="zoom:50%;" /> 

A new operation interface then appears:

<img src="https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172322451.png" style="zoom: 67%;" />

Button Explanation:

- **p4~cp1**: Selects a channel for interpolation (red highlight indicates selection).
- **Interp Sel Chann**: Interpolates the selected channels. Each execution creates a separate copy of the original data for safe experimentation.
- **Plot Unsel Chann**: Displays waveforms of unselected electrodes.
- **Plot aft Interp**: Displays waveforms after interpolation.
- **Done & Save**: Ends the process and saves the data.

The interpolated dataset is stored in the `subjx/set/afterInterp` directory.

#### ICA (Independent Component Analysis)

After clicking **Done & Save**, the next step automatically runs ICA. The ICA-processed data is stored in the `/subjx/set/afterICA/` directory.

#### Artifact Removal

Once ICA completes, the tool moves to artifact marking. The following window appears:

<img src="https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172336921.png" style="zoom:67%;" />

Click **Flag Artifacts** to mark artifacts based on the threshold values set in the earlier configuration file.

A new popup displays marked channels:

<img src="https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172338042.png" style="zoom: 67%;" />

Button Explanation:

- **Preview Rejection**: Displays waveforms after artifact removal.
- **Confirm**: Confirms the action to remove artifacts and saves the data.
- **Cancel**: Cancels the operation for further threshold adjustments.

The dataset post-artifact removal is stored in `/subjx/set/afterArtifact`.

------

### **Calculate Data**

This step performs time-frequency domain analysis of EEG and EMG data using datasets from `/subjx/set/afterArtifact`.

The tool uses Morlet wavelet transformations to calculate correlation matrices. Results are saved in:
`rootDataDir/CMCresults_lowerLimb/subjx/`

------

### **Plot Data**

Correlation figures are drawn, saved, closed, and proceed to the next dataset sequentially.
An example output is shown below:

![img](https://cdn.jsdelivr.net/gh/DyingDown/img-host-repo/202501172351494.png)

Images are saved in:
`dataRootDir/CMCplots_lowerLimb/subjx`

------

### **Plot Coh Avg**

Calculates average correlation data to generate averaged time-frequency domain plots, useful for smoothing uneven correlation data.

To proceed, group the datasets (in `.mat` format) into a single folder.

Clicking this button prompts directory selection, and results are saved in the chosen folder.