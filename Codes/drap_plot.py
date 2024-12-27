import os,numpy as np
import matplotlib.pyplot as plt
import scipy.io

import matplotlib
matplotlib.use('TkAgg')  # 指定使用 Tk 后端，或根据需要选择合适的后端


plt.rcParams['figure.max_open_warning'] = 0
# Define the number of experiments
num_experiments = 4

# Store the average values of within-group variables
#被试现在有两人
subject = [1,2]
file_path = 'D:/Documents/Peng/zhengda/CMCresult_lowerLimb/CMCvalues/'

# Two types of motion: 'a' and 'b'
motion_type = ['a','b']
# Store frequency domain CMC data
EEGsch_name = ['C3','C4']
EMGsch_name = ['MG','RF']
#不是双向
CMC_num = len(EEGsch_name)*len(EMGsch_name)
subject_means = np.zeros((CMC_num,num_experiments, 5))

# Add vertical lines and text labels for frequency band divisions
alpha_freq = np.array([8,13])  # α frequency band
beta_freq = np.array([13,30])  # β frequency band
gamma_freq = np.array([30,49])  # γ frequency band
delta_freq = np.array([1,4])  # δ frequency band
theta_freq = np.array([4,8])  # θ frequency band

CMC = {}
Freq = np.arange(1,50,0.196)
for name1 in EEGsch_name:
    for name2 in EMGsch_name:
        for name2 in EMGsch_name:
            CMC['wcohere_'+name2+'_'+name1] = {} 

# 使用布尔索引选择满足条件的索引——————左闭右开
alpha_indices = np.where((Freq >= np.min(alpha_freq)) & (Freq < np.max(alpha_freq)))[0]
beta_indices = np.where((Freq >= np.min(beta_freq)) & (Freq < np.max(beta_freq)))[0]
gamma_indices = np.where((Freq >= np.min(gamma_freq)) & (Freq < np.max(gamma_freq)))[0]
delta_indices = np.where((Freq >= np.min(delta_freq)) & (Freq < np.max(delta_freq)))[0]
theta_indices = np.where((Freq >= np.min(theta_freq)) & (Freq < np.max(theta_freq)))[0]
print(gamma_indices)
# Loop through each experiment
for subject_id in subject:
    for motion in motion_type:
        for i in range(1, num_experiments + 1):
            # Generate the experiment filename
            filename = f'subj{subject_id}_s{i:02d}_preped_dir_{motion}_CMCvalues(MG&RF).mat'

            # Read the experiment data
            data = scipy.io.loadmat(file_path + filename)
            # Calculate frequency domain CMC (sum along rows)
            for name1 in EEGsch_name:
                for name2 in EMGsch_name:
                    #1代表对第二个维度处理
                    CMC['wcohere_'+name2+'_'+name1]['s0'+str(i)] = np.mean(data['wcohere_'+name2+'vs'+name1], axis=1)
            
            for k in range(CMC_num):
                # print(CMC[list(CMC.keys())[k]]['s0'+str(i)])
                alpha_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][alpha_indices])
                beta_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][beta_indices])
                gamma_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][gamma_indices])
                delta_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][delta_indices])
                theta_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][theta_indices])
                subject_means[k, i-1, :] = [alpha_mean, beta_mean, gamma_mean, delta_mean, theta_mean]

        plot_path = f'D:/Documents/Peng/zhengda/CMCresult_lowerLimb/CMC_Freq/subj{subject_id}/{motion}/'
        dir_subj = f'D:/Documents/Peng/zhengda/CMCresult_lowerLimb/CMC_Freq/subj{subject_id}/'

# 检查和创建子目录
os.makedirs(dir_subj, exist_ok=True)

for motion in motion_type:
    dir_motion = os.path.join(dir_subj, motion)
    os.makedirs(dir_motion, exist_ok=True)

    # 遍历 EEG 和 EMG 频道名称组合
    for idx, (name1, name2) in enumerate([(e, m) for e in EEGsch_name for m in EMGsch_name]):
        key = f'wcohere_{name2}_{name1}'

        # 绘制结果并保存为图片
        plt.figure()
        plt.plot(Freq, CMC[key]['s0'+str(i)], label='CMC Spectrum')
        plt.axvspan(alpha_freq[0], alpha_freq[1], color='blue', alpha=0.2, label='Alpha Band')
        plt.axvspan(beta_freq[0], beta_freq[1], color='green', alpha=0.2, label='Beta Band')
        plt.axvspan(gamma_freq[0], gamma_freq[1], color='red', alpha=0.2, label='Gamma Band')
        plt.axvspan(delta_freq[0], delta_freq[1], color='yellow', alpha=0.2, label='Delta Band')
        plt.axvspan(theta_freq[0], theta_freq[1], color='purple', alpha=0.2, label='Theta Band')

        plt.bar(x - width/2, values1, width=width, label='Group 1', color='blue')

        plt.title(f'CMC Spectrum for {name1}-{name2}')
        plt.xlabel('Frequency (Hz)')
        plt.ylabel('CMC Value')
        plt.legend()
        plt.grid(True)

        # 保存路径
        save_path = os.path.join(dir_motion, f'CMC_{name1}_{name2}_s{i:02d}.png')
        print(save_path)
        plt.savefig(save_path)
        # plt.close()

print("Processing complete. All plots and results saved.")