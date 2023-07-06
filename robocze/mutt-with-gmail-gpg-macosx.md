# Mutt (or NeoMutt) with Gmail and GPG, Mutiple Accounts

This note describes how to set up the [Mutt](http://www.mutt.org/) or
[NeoMutt](https://neomutt.org/) email client to work for Gmail and
GnuPG, for two Gmail accounts. The method can be trivially extended to
more than two accounts. The configuration should work for both macOS
and Linux.

## Software versions

The software versions used in this note are:

- macOS Catalina (version 10.15.4)
- Mutt 1.13.5 (installed with `brew install mutt`) or NeoMutt 20200320
(installed with `brew install neomutt`)
- gpg (GnuPG) 2.2.20, libcrypt 1.8.5 (installed with `brew install gnupg`)

In the rest of the document, we will use Mutt as an example. The
configurations for Mutt and NeoMutt are identical.

## Configure Gmail for each account

Sign in with the Google/Gmail account, and follow the instructions
provided in Google support page [Sign in using App
Passwords](https://support.google.com/accounts/answer/185833) to obtain
an app password dedicated for Mutt). You will need to first enable
"2-step authentication" for your Google account if it has not been done.
Select the app and devices as "Mail" and "Mac", respectively. Write down
the generated app password for Mutt configuration later.

## Configure Mutt

1. Create directory `.mutt` in your home directory, and the following
files in `~/.mutt/`:

   ```text
   .mutt
   ├── common.rc
   ├── mailcap
   ├── muttrc
   ├── username1.app-password.gpg
   ├── username2.app-password.gpg
   ├── username1.rc
   └── username2.rc
   ```

2. GPG encrypt the account's app password setting, and save the
encrypted text in file `~/.mutt/<username>.app-password.gpg`, where
`<username>` is the Gmail username for the account (`username1` or
`username2` in this demo), as follows

   ```bash
   gpg --recipient <username>@gmail.com --encrypt --armor > <username>.app-password.gpg
   ```

   In console window, manually enter the following information (`^D` is the key combination `Ctrl-d`)
  
   ```bash
   set imap_pass = <app password for username>
   set smtp_pass = <app password for username>
   ^D
   ```

3. Configure Mutt's main configuration file. Add the following content
to `~/.mutt/muttrc` to set up key bindings (`F2` for `username1`, `F3`
for `username2`)

   ```text
   # muttrc
   # Default account
   source ~/.mutt/username1.rc

   # Macros for switching accounts
   macro index <f2> '<sync-mailbox><enter-command>source ~/.mutt/username1.rc<enter><change-folder>!<enter>'
   macro index <f3> '<sync-mailbox><enter-command>source ~/.mutt/username2.rc<enter><change-folder>!<enter>'
   ```

4. Account-specific configuration files `~/.mutt/username1.rc` and
`~/.mutt/username2.rc`. You need to manually tweak these files to make
sure they contain the desired values for `my_GID`, `hostname`, `realname`, and
`from`.

   ```text
   # username1.rc
   # Gmail user ID. User variable in Mutt must start with "my"
   set my_GID = "username1"
   # Use a fake hostname so Message-ID header does not leak info
   set hostname = fake-hostname1
   set realname = "First1 Last1"
   set from = $my_GID@gmail.com

   # Load common configurations
   source ~/.mutt/common.rc
   ```

   ```text
   # username2.rc
   # Gmail user ID. User variable in Mutt must start with "my"
   # CHANGEME
   set my_GID = "username2"
   # Use a fake hostname so Message-ID header does not leak info
   set hostname = fake-hostname2
   set realname = "First2 Last2"
   # Change 'from' when, say, you want to use another address backed by Gmail
   set from = $my_GID@gmail.com

   # Load common configurations
   source ~/.mutt/common.rc
   ```

5. The remaining configuration files are common for all accounts.

   ```text
   # common.rc
   # Common configurations
   # For a full list a configuration variables, see 
   # https://muttmua.gitlab.io/mutt/manual-dev.html#variables

   ############################
   # GPG configuration
   ############################
   # Load gpg encrypted IMAP and SMTP app passwords
   source "gpg --decrypt ~/.mutt/$my_GID.app-password.gpg |"

   # Use GPGME
   set crypt_use_gpgme = yes

   # Don't sign, so I'm not legally liable to what I say in encrypted email
   set crypt_autosign = no
   # Encrypt replies to PGP emails by default
   set crypt_replyencrypt = yes

   ############################
   # Mail configuration
   ############################
   # Timeout
   set pgp_timeout = 1800
   set use_from = yes
   set envelope_from = yes

   set folder = "imaps://imap.gmail.com:993"
   set smtp_url = "smtps://$my_GID@smtp.gmail.com:465/"
   set smtp_authenticators = 'gssapi:login'
   set imap_user = $my_GID@gmail.com
   set spoolfile = "+INBOX"
   set trash = "+Trash"

   # SSL hardening
   set ssl_force_tls = yes
   set ssl_starttls = yes
   #set ssl_use_sslv2 = no
   #set ssl_use_sslv3 = no
   #set ssl_use_tlsv1 = no
   set ssl_use_tlsv1_1 = no
   set ssl_use_tlsv1_2 = yes
   #set ssl_use_tlsv1_3 = yes
   set ssl_verify_dates = yes
   set ssl_verify_host = yes
   #set ssl_usesystemcerts = yes

   # html email
   set mailcap_path = ~/.mutt/mailcap
   auto_view text/html  # view html automatically
   alternative_order text/plain text/enriched text/html # save html for last

   # G to get mail
   bind index G imap-fetch-mail
   set editor = "vim"
   set charset = "utf-8"
   set record = ''
   ```

   ```text
   # mailcap.rc
   # On Debian: apt install w3m w3m-img
   text/html; \
   w3m -I %{charset} -T text/html; copiousoutput;
   ```
