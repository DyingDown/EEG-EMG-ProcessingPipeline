import os,numpy as np
import matplotlib.pyplot as plt
import scipy.io

# %matplotlib nbagg

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
gamma_freq = np.array([30,50])  # γ frequency band
delta_freq = np.array([1,4])  # δ frequency band
theta_freq = np.array([4,8])  # θ frequency band

CMC = {}
Freq = np.arange(1,50,0.196)
print(len(Freq))
for name1 in EEGsch_name:
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
                # print("CMC 数据长度:", len(CMC[list(CMC.keys())[k]]['s0'+str(i)]))

                alpha_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][alpha_indices])
                beta_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][beta_indices])
                gamma_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][gamma_indices])
                delta_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][delta_indices])
                theta_mean = np.mean(CMC[list(CMC.keys())[k]]['s0'+str(i)][theta_indices])
                subject_means[k, i-1, :] = [alpha_mean, beta_mean, gamma_mean, delta_mean, theta_mean]

        plot_path = f'D:/Documents/Peng/EEG/Datasets/CMCresult_lowerLimb/CMC_Freq/subj{subject_id}/{motion}/'
        dir_subj = f'D:/Documents/Peng/EEG/Datasets/CMCresult_lowerLimb/CMC_Freq/subj{subject_id}/'
        if not os.path.exists(dir_subj):
            os.makedirs(dir_subj)
        if not os.path.exists(plot_path):
            os.makedirs(plot_path)
                # Plot the bar chart
        for j in range(CMC_num):
            plt.figure()
            x = np.arange(5)
            heights = subject_means [j,:,:]

            for i, height in enumerate(heights):
                x = np.arange(5) + i*0.2  # 调整x坐标，使每个主题的柱形图错开
                plt.bar(x, height, width=0.2, label=f's0{i+1}')  # 绘制每个主题的柱形图，并添加标签
            print("plot 1 ploted")
            tit2 = f'Freq_div-subj{subject_id}-{motion}-{list(CMC.keys())[j]}'
            plt.title(tit2)
            plt.xlabel('Freq')
            plt.ylabel('CMC')
            plt.legend()
            plt.xticks(np.arange(5), ['α', 'β', 'γ', 'δ', 'θ'])
            plt.show()
            plt.savefig(plot_path + f'{tit2}.png')
            print("plot saved ", plot_path + f'{tit2}.png')
            plt.figure()
            temp_max = np.zeros((4, 1))
            for i in range(1, num_experiments + 1):
                x = Freq
                y = CMC[list(CMC.keys())[j]]['s0'+str(i)]
                plt.plot(x, y, label=f's{i:02d}')
                temp_max[i-1,0] = np.max(y)
            Max = np.max(temp_max)
            plt.axvline(x=alpha_freq[0], linestyle='--', color='red')
            plt.axvline(x=alpha_freq[-1], linestyle='--', color='red')
            plt.text(alpha_freq[0], Max, 'α', ha='left', va='bottom')

            plt.axvline(x=beta_freq[0], linestyle='--', color='blue')
            plt.axvline(x=beta_freq[-1], linestyle='--', color='blue')
            plt.text(beta_freq[0], Max, 'β', ha='left', va='bottom')

            plt.axvline(x=gamma_freq[0], linestyle='--', color='green')
            plt.axvline(x=gamma_freq[-1], linestyle='--', color='green')
            plt.text(gamma_freq[0], Max, 'γ', ha='left', va='bottom')

            plt.axvline(x=delta_freq[0], linestyle='--', color='orange')
            plt.axvline(x=delta_freq[-1], linestyle='--', color='orange')
            plt.text(delta_freq[0], Max, 'δ', ha='left', va='bottom')

            plt.axvline(x=theta_freq[0], linestyle='--', color='purple')
            plt.axvline(x=theta_freq[-1], linestyle='--', color='purple')
            plt.text(theta_freq[0], Max, 'θ', ha='left', va='bottom')
            
            tit1 = f'Freq-subj{subject_id}-{motion}-{list(CMC.keys())[j]}'
            plt.title(f'Freq-subj{subject_id}-{motion}-{list(CMC.keys())[j]}')
            plt.xlabel('Frequency')
            plt.ylabel('CMC')
            plt.xlim(0, 50)
            plt.legend()
            plt.show()
            plt.savefig(plot_path + f'{tit1}.png')
            
