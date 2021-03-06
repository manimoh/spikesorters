function p_waveclus(vcDir_temp, nChans, par_input)
    % Arguments
    % -----
    % nChans: number of channels, if more than 1 the polytrode
    % par_input: wave_clus parameters defined by the user
    % version of wave_clus will be applied

    S_par = set_parameters_ss();
    S_par = update_parameters(S_par,par_input,'relevant');

    cd(vcDir_temp);

    for nch = 1: nChans
        vcFile_mat{nch} = fullfile(vcDir_temp, ['raw' int2str(nch) '.mat']);
    end
    if nChans==1
        % Run waveclus batch mode. supply parameter file (set sampling rate)
        Get_spikes(vcFile_mat{1}, 'par', S_par);
        vcFile_spikes = strrep(vcFile_mat{1}, '.mat', '_spikes.mat');
        Do_clustering(vcFile_spikes, 'make_plots', false);
        [vcDir_, vcFile_, vcExt_] = fileparts(vcFile_mat{1});
        vcFile_cluster = fullfile(vcDir_, ['times_', vcFile_, vcExt_]);
    else
        % Run waveclus batch mode. supply parameter file (set sampling rate)
        elec_group = 1; %for now, only one group supported
        pol_name = ['polytrode' num2str(elec_group)];
        pol_fname = [pol_name '.txt'];
        pol_file = fopen(pol_fname,'w');
        cellfun(@(x) fprintf(pol_file ,'%s\n',x),vcFile_mat);
        fclose(pol_file);
        Get_spikes_pol(elec_group, 'par', S_par);
        vcFile_spikes = strrep(pol_fname, '.txt', '_spikes.mat');
        Do_clustering(vcFile_spikes, 'make_plots', false);
        [vcDir_, ~, vcExt_] = fileparts(vcFile_mat{1});
        vcFile_cluster = fullfile(vcDir_, ['times_', pol_name, vcExt_]);
    end
    
    movefile(vcFile_cluster,fullfile(vcDir_, 'times_results.mat'))
end