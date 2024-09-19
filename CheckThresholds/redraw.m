function redraw(frame, vidObj, freeze_idx)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

% Read frame
f = vidObj.read(frame);

f = insertText(f,[0 0], sprintf('Frame: %d', frame));

if frame > 1
    if freeze_idx(frame-1)
        I = insertText(f,[250 0], 'Freezing', 'TextBoxColor', 'red', 'FontSize', 15);
    else
        I = insertText(f,[260 0], 'Moving', 'TextBoxColor', 'green', 'FontSize', 15);
    end
else
    I = f;
end

% Display
image(I); axis image off

end