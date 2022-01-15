# Pinentry Rofi

Ever wanted to use your awesome riced up [Rofi Dmenu](https://github.com/davatorium/rofi)
as a pinentry tool for programs like OpenSSH and GnuPG (or anything else that uses pinentry)?

**Well now you can!**

## Installation

```
sudo make install
```

You may need to udpate the  symbolic link of your current pinentry program, or update some configuration file for the program you are using *(gpg uses gpg-anget.conf to specify pinentry if needed)*.
