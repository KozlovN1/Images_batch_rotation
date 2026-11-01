% An initialization subroutine.
% Version 1.5 (2025-02-26)
% Nick Kozlov
%
% -------------------------------------------------
% MIT License
% 
% Copyright (c) 2025 Nick Kozlov (KozlovN1 @ github)
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

prompt = strcat('Do you want to CLEAN and restart over?');
dlgtitle = 'Restart over: y/n?';
defbtn = 'No';
answer = questdlg(prompt,dlgtitle, ...
    'Yes', 'No', 'Abort', defbtn);

switch answer
    case 'Yes'
        clc; clear all; close all;
    case 'No'
    case 'Abort'
        msgbox('STOP: Operation aborted by user.')
        assert(false, 'STOP: Operation aborted by user.')
end