% Execute MHA with MHAIOalsa 
% and check that the  expected output sound file is produced.
%
% This file is part of the HörTech Open Master Hearing Aid (openMHA)
% Copyright © 2018 HörTech gGmbH

% openMHA is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published by
% the Free Software Foundation, version 3 of the License.
%
% openMHA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License, version 3 for more details.
%
% You should have received a copy of the GNU Affero General Public License, 
% version 3 along with openMHA.  If not, see <http://www.gnu.org/licenses/>.

%This test needs the alsa loopback device module installed
%This module is usually called snd_aloop or snd-aloop
%and is found in the linux-image-extra package
%After installation it can be activated with
%>modprobe snd-aloop

function test_mhaioalsa

%This test can not run on Windows or macOS
assert_equal(ispc(),false);
assert_equal(ismac(),false);
%Clean up after we are finished
inwav = 'IN.wav';
outwav = 'OUT.wav';
unittest_teardown(@delete, [inwav]);
unittest_teardown(@delete, [outwav]);
fclose(fopen(inwav, 'w'));
fclose(fopen(outwav, 'w'));
%Check if snd_aloop module is loaded
[~,result]=system('grep -e "^snd_aloop " /proc/modules');
[status,~]=system(['test -n "' result '"']);
assert_equal(0,status);
%Create random noise, write to temp file
snd_in=repeatable_rand(16000,1,0);
audiowrite(inwav,snd_in,16000);
%Setup mha to use alsa loopback device
mha = mha_start;
unittest_teardown(@mha_set, mha, 'cmd', 'quit');
mha_set(mha,"nchannels_in",1);
mha_set(mha,"srate",16000);
mha_set(mha,"fragsize",1024);
mha_set(mha,"iolib","MHAIOalsa");
mha_set(mha,"io.link","no");
mha_set(mha,"io.format","S16_LE");
%The loopback device creates two dummy soundcards
%Input from Loopback,0 is sent to the output of Loopback,1
%and vice versa. This way we can create a processing chain
%file->alsa->mha->alsa->file and check if what we put in is what we get out.
mha_set(mha,"io.in.device","plughw:Loopback,0,0");
mha_set(mha,"io.out.device","plughw:Loopback,0,0");
mha_set(mha,"io.priority",90);
mha_set(mha,"mhalib","identity");
mha_set(mha,'cmd','start');
%Play sound and simultaneously record back
system('aplay -D plughw:Loopback,1,0 -f S16_LE -c 1 -r 16000 IN.wav 1>/dev/null 2>&1 &');
system('arecord -D plughw:Loopback,1,0 -d 1 -t wav -f S16_LE -c 1 -r 16000 OUT.wav 1>/dev/null 2>&1');
snd_out=audioread(outwav);
%Check for equality
snd_out=snd_out(find(snd_out,1):end);   %Remove silence at beginning of recording
snd_in=snd_in(1:size(snd_out,1));
assert_difference_below(snd_in,snd_out,1e-3);
end

% Local Variables:
% mode: octave
% coding: utf-8-unix
% indent-tabs-mode: nil
% End:
