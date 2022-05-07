W Dell-u Vostro 3550 występuje następujący problem z dźwiękiem, podczas odtwarzania muzyki przy podpiętych słuchawkach dzwięk jest odtwarzany jednocześnie na słuchawkach i jednocześnie na głośnikach laptopa. 
Zaradzić temu można wyłączając źródło przypisane do gniazda słuchawkowego (dac-0:1) następnie włączyć źródło przypisane do głośników (dac-2:3), i przypisać je na przemian czyli dac-0:1 do głośników a dac-2:3 do słuchawek.
Poniżej znajdują się polecenia za pomocą, których możemy to wykonać. Możemy również skorzystać ze znajdującego się w tym katalogu skryptu.
Te ustawienia spowodują że dzwięk będzie odtwarzany tylko na gnieździe słuchawkowym, aby odtwarzać dzwięk tylko na głośnikach laptopa, zamieniamy tylko ze sobą źródła.


$ doas mixerctl inputs.dac-0:1_mute=on  
$ doas mixerctl inputs.dac-2:3_mute=off
$ doas mixerctl outputs.hp_source=dac-2:3
$ doas mixerctl outputs.spkr_source=dac-0:1

