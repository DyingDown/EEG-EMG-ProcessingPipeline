% clc
% clear all

%{
    该文件用来对数据进行预处理
        - 加载数据到eeglab，其中包括电极位置信息，元数据，事件信息
        - 对数据进行滤波
        - ...未完待续
%}


% 加载subj1_raw_processed_s01、chanlocs、events_info并添加EMG通道标签

function eeglab_process(baseDataFolder)

    eeglab;

    folders = dir(baseDataFolder);  % 获取当前目录下的所有文件和文件夹
    disp(folders)
    for j = 1:length(folders)
        % 跳过 . 和 .. 这两个特殊文件夹
        if strcmp(folders(j).name, '.') || strcmp(folders(j).name, '..')
            continue;
        end
        disp(class(folders(j).name))
        % if ~strcmp(folders(j).name, 'subj5')
        %     continue;
        % end
        
    
        % 拼接完整路径
        fullPath = fullfile(baseDataFolder, folders(j).name);
        % 判断是否是文件夹，并且文件夹名符合条件
        if folders(j).isdir && matches_subj_pattern(folders(j).name)
            fprintf('符合条件的文件夹：%s\n', fullPath);
            % 如果满足条件，对其子文件夹递归调用
            % traverse_folders(fullPath);
            originalDataFolders = fullfile(fullPath, "/filtered");
            % 获取文件夹中的所有文件和文件夹（包括隐藏文件）
            fileList = dir(originalDataFolders);
            
            % 排除 '.' 和 '..' 文件夹
            fileList = fileList(~ismember({fileList.name}, {'.', '..'}));
    
            for i = 1:length(fileList)
                fileName = fileList(i).name;  % 获取文件或文件夹的名字
                filepath = fullfile(originalDataFolders, fileName);  % 获取完整路径
                fprintf("当前处理的的文件是：%s\n",filepath);
                
                setname = extractBefore(fileName, "_raw_processed");
    
                flagFile = fullfile(fullPath, "set", "flags", [setname, '.mat']);
                disp(['flagFile: ' flagFile])
                stepFlags = get_flag_step(flagFile);
    
                if stepFlags.loadSet == false
                    % mannual interpolate electrodes
                    [EEG, stepFlags] = load_set(baseDataFolder, fullPath, filepath, fileName, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "beforeInterp"))); 
                    disp("Set already Loaded.")
                end
                
                if stepFlags.interpolate == false
                    [EEG, stepFlags] = mannual_interp(EEG, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "afterInterp"))); 
                    disp("Interpolation already done");
                end
    
                if stepFlags.runICA == false
                    [EEG, stepFlags] = run_ICA(EEG, fullPath, setname, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "afterICA"))); 
                    disp("ICA already done");
                end
    
                if stepFlags.flagArtifacts == false
                    [EEG, stepFlags] = flag_artifacts(EEG, fullPath, setname, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "afterArtifact"))); 
                    disp("Remove Artifacts already done");
                end
    
            end
        end
    end
end

    


% 对_beforeInterpol手动插值坏导,去除质量差的数据段-ManuRej;
% 跑ICA,记得选择通道类型EEG。-ICA;
% 用IClabel,剔除无用IC得到-preped;

% EMG影响观看时。
% EEG_a = EEG; 
% for i = 1:8
%     EEG_a.data(i,:) = EEG_a.data(i,:)*0;
% end
% pop_eegplot( EEG_a, 1, 1, 1); 
% 
% 
% % zhikanC3。
% EEG_a = EEG;
% for i = 1:22
%     if i == 10
%         continue;
%     end
%     EEG_a.data(i,:) = EEG_a.data(i,:)*0;
% end
% pop_eegplot( EEG_a, 1, 1, 1); 





% %单看EMG    
% EEG_b = EEG;
% for i = 9:24
%     EEG_b.data(i,:) = EEG_b.data(i,:)*0;
% end
% pop_eegplot( EEG_b, 1, 1, 1); 


%错误实例
%{

% 生成epochs
EEG_a = pop_epoch( EEG, {  'a'  }, [0         5.4], 'newname', 'subj1_s01_interpol epochs_a', 'epochinfo', 'yes');
EEG_b = pop_epoch( EEG, {  'b'  }, [0         3], 'newname', 'subj1_s01_interpol epochs_b', 'epochinfo', 'yes');
pop_eegplot( EEG_a, 1, 1, 1);

%%% 剔除坏段-有需要运行
to_delete = false(1, EEG.trials);  % 全部初始化为false
to_delete([1]) = true;  % 设置要删除的epoch的索引为true
% 使用pop_select函数删除指定索引的epoch
EEG_a = pop_select(EEG_a, 'notrial', to_delete);
pop_eegplot( EEG_a, 1, 1, 1);

file_path={'D:\EEG\外骨骼项目\data_rename\subj1\sitstand' 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\epoch'};
file_name = 'subj1_s01_a';
EEG_a = pop_saveset( EEG_a, 'filename',[file_name '_Epo.set'],'filepath',file_path{2});


%%% b %%%
pop_eegplot( EEG_b, 1, 1, 1);

%%% 剔除坏段-有需要运行
to_delete = false(1, EEG.trials);  
to_delete([]) = true;  
EEG_b = pop_select(EEG_b, 'notrial', to_delete);
pop_eegplot( EEG_b, 1, 1, 1);

file_path={'D:\EEG\外骨骼项目\data_rename\subj1\sitstand' 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\epoch'};
file_name = 'subj1_s01_b';
EEG_b = pop_saveset( EEG_b, 'filename',[file_name '_Epo.set'],'filepath',file_path{2});

}%

% runICA
file_name = 'subj1_s01_a';
file_path={'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\epoch' 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\ICA'};
EEG = pop_loadset('filename',[file_name  '_Epo.set'],'filepath',file_path{1});%导入.set数据

EEG = pop_select(EEG, 'channel', 'EEG');
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','pca',14);%因为插值两个坏导
EEG = pop_iclabel(EEG, 'default');
EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %保存数据

%剔除IC
EEG = pop_iclabel(EEG, 'default');
EEG = pop_subcomp( EEG, [4  7  8  9], 0);
EEG.setname='subj1_s01_a_preped';
%有问题。
EEG = eeg_checkset( EEG );
file_path = 'D:\EEG\外骨骼项目\data_rename\subj1\sitstand\preped'
EEG = pop_saveset( EEG, 'filename',[file_name  '_preped.set'],'filepath',file_path); %保存数据












%{
file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\ICA'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');%runICA
    EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %保存数据
end
%}






%{
file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\EDF' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set'};
for i=1:6%需要修改
    file_name=[num2str(i)];
    EEG = pop_biosig(strcat(file_path{1},'\',[file_name '.edf']) );
    EEG = eeg_checkset( EEG );
    EEG=pop_chanedit(EEG, 'lookup','E:\\MATLAB工具包\\eeglab12_0_2_6b\\plugins\\dipfit2.2\\standard_BESA\\standard-10-5-cap385.elp');
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'nochannel',{'HEO' 'VEO' 'Trigger' 'CB1' 'CB2'});
    EEG = eeg_checkset( EEG );
    EEG = pop_resample( EEG, 500);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [], 1, 1650, true, [], 1);%按照之前的参数滤波
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [], 40, 166, 0, [], 1);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[file_name '.set'],'filepath',file_path{2});
    EEG = eeg_checkset( EEG );
end

%手动去坏段，插值坏导

%跑ica

file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\ICA'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');%runICA
    EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %保存数据
end






%转参考
file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\ICA' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\REF'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '_ICA.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );%全脑平均参考
    EEG = pop_saveset( EEG, 'filename',[file_name  '_REF.set'],'filepath',file_path{2}); %保存数据
end





%分段

file_path={'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\REF' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\epoch'};
for i =1:6;%需要修改
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '_REF.set'],'filepath',file_path{1});%导入.set数据
    EEG = pop_epoch( EEG, {  '2'  }, [-0.2         0.8], 'newname', 'EDF file resampled epochs', 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-200    0]);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[file_name  '_EPOCH.set'],'filepath',file_path{2}); %保存数据
end


%}


































%{
file_path={'D:\\EEG\\外骨骼项目\\data_rename' 'C:\Users\jd\Desktop\广州培训班\预处理部分\raw_data\set'};
i = 1;
k = 1;
subj_num =[num2str(i)];
session = [num2str(k)];
file_name = strcat('s0',session);
txt_path = strcat(file_path{1},'\','subj',subj_num,'\sitstand\',[file_name '.txt']);
EEG = pop_importdata('dataformat','ascii','nbchan',0,'data',txt_path,'setname','test_history','srate',1000,'pnts',0,'xmin',0,'chanlocs','D:\\EEG\\外骨骼项目\\data_rename\\code_locs\\32eegemg_sitstand_locs.ced');
%给EMG通道添加标签
EEG=pop_chanedit(EEG, 'changefield',{1,'type','EMG'},'changefield',{2,'type','EMG'},'changefield',{3,'type','EMG'},'changefield',{4,'type','EMG'},'changefield',{5,'type','EMG'},'changefield',{6,'type','EMG'},'changefield',{7,'type','EMG'},'changefield',{8,'type','EMG'});
%}

    
%}

