#!/bin/ksh

mixerctl inputs.dac-0:1_mute=on;
mixerctl inputs.dac-2:3_mute=off;
mixerctl outputs.hp_source=dac-2:3;
mixerctl outputs.spkr_source=dac-0:1;
