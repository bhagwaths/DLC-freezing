function redraw(frame, vidObj, idx, behavior)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

% Read frame
f = vidObj.read(frame);

f = insertText(f,[0 0], sprintf('Frame: %d', frame), 'FontSize', round(vidObj.Width/30));

if strcmp(behavior,'freezing')
    if frame > 1
        if idx(frame-1)
            I = insertText(f,[vidObj.Width-(vidObj.Width/6) 0], 'Freezing', 'TextBoxColor', 'red', 'FontSize', round(vidObj.Width/30));
        else
            I = insertText(f,[vidObj.Width-(vidObj.Width/6)+(vidObj.Width/60) 0], 'Moving', 'TextBoxColor', 'green', 'FontSize', round(vidObj.Width/30));
        end
    else
        I = f;
    end
elseif strcmp(behavior,'struggle')
    if frame > 1
        if idx(frame-1)
            I = insertText(f,[vidObj.Width-(vidObj.Width/6)-(vidObj.Width/40) 0], 'Struggling', 'TextBoxColor', 'red', 'FontSize', round(vidObj.Width/30));
        else
            I = f;
        end
    else
        I = f;
    end
end

% Display
image(I); axis image off

end