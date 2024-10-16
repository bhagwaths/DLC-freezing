function redraw(frame, vidObj, idx, behavior)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

% Read frame
f = vidObj.read(frame);

f = insertText(f,[0 0], sprintf('Frame: %d', frame), 'FontSize', 20);

if strcmp(behavior,'freezing')
    if frame > 1
        if idx(frame-1)
            I = insertText(f,[250 0], 'Freezing', 'TextBoxColor', 'red', 'FontSize', 15);
        else
            I = insertText(f,[260 0], 'Moving', 'TextBoxColor', 'green', 'FontSize', 15);
        end
    else
        I = f;
    end
elseif strcmp(behavior,'struggle')
    if frame > 1
        if idx(frame-1)
            I = insertText(f,[550 0], 'Struggle', 'TextBoxColor', 'red', 'FontSize', 20);
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