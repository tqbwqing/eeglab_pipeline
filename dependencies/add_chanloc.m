function EEG = add_chanloc(EEG, brainTemplate, onlineRef, appendOnlineRef)
    
% add channel locations & recover online reference 
% e.g. EEG = addChanLoc(EEG, 'Spherical', 'FCz', true)
    
    eeglabDir = fileparts(which('eeglab.m'));
    switch brainTemplate
      case 'MNI'
        locFile = 'standard_1005.elc';
        chanLocDir = fullfile(eeglabDir, 'plugins', 'dipfit2.3', 'standard_BEM', ...
                              locFile);
      case 'Spherical'
        locFile = 'standard-10-5-cap385.elp';
        chanLocDir = fullfile(eeglabDir, 'plugins', 'dipfit2.3', 'standard_BESA', ...
                              locFile);
      case 'EGI65'  % EGI 64 electrodes cap
        locFile = 'EGI65.elp'; 
        chanLocDir = which(locFile);
    end

    % add channel locations
    EEG = pop_chanedit(EEG, 'lookup', chanLocDir); % add channel location
    EEG = eeg_checkset(EEG);

    % check if onlineRef exist
    if any(ismember({EEG.chanlocs.labels}, onlineRef))
        doNotAppend = true;
    else
        doNotAppend = false;
    end
    
    if ~doNotAppend && appendOnlineRef
            nChan = size(EEG.data, 1);
            EEG = pop_chanedit(EEG, 'append', nChan, ...
                               'changefield',{nChan+1, 'labels', onlineRef}, ...
                               'lookup', chanLocDir, ...
                               'setref',{['1:',int2str(nChan+1)], onlineRef}); % add online reference
            EEG = eeg_checkset(EEG);
            newChanLoc = createChanLoc(onlineRef, nChan+1);
            EEG = pop_reref(EEG, [], 'refloc', newChanLoc); % retain online reference data back
            EEG = eeg_checkset(EEG);
            EEG = pop_chanedit(EEG, 'lookup', chanLocDir, 'setref',{['1:', int2str(size(EEG.data, 1))] 'average'});
            EEG = eeg_checkset(EEG);
            chanlocs = pop_chancenter(EEG.chanlocs, []);
            EEG.chanlocs = chanlocs;
            EEG = eeg_checkset(EEG);
    else
        disp('do not need to append online reference');
    end

function newChanLoc = createChanLoc(chan, n)

    newChanLoc = struct('labels', chan,...
                        'type', [],...
                        'theta', [],...
                        'radius', [],...
                        'X', [],...
                        'Y', [],...
                        'Z', [],...
                        'sph_theta', [],...
                        'sph_phi', [],...
                        'sph_radius', [],...
                        'urchan', n,...
                        'ref', n,...
                        'datachan', {0});
