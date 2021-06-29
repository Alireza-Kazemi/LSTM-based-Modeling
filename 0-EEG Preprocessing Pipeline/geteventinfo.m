function eventinfomat=geteventinfo(eegevent)

% Generate eventinfo matrix from eeg.event structure
% Input: eeg.event (from eeglab)
% Output: type (col1), latency (col2)

eventinfo=struct2cell(eegevent);
if size(eventinfo,3) > 1
    eventinfo=squeeze(eventinfo)';
    n_event=length(eventinfo);
    for ii=1:n_event
        eventinfomat(ii,1)=double(eventinfo{ii,1});
        eventinfomat(ii,2)=double(eventinfo{ii,2});
    end
else
    n_event=size(eventinfo{1},1);
    eventinfomat(:,1)=eventinfo{1};
    eventinfomat(:,2)=eventinfo{2};
end

end

