#!/usr/bin/emacs --script
;;; install.el --- gtags layer dependencies installation script
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Eugene "JAremko" Yaremenko <w3techplayground@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(load "/usr/local/spacemacs/lib/deps-dsl.el" nil t)

(checkpoint
  (let ((global-version "6.5.5"))
    (install python-pygments libncurses-dev)
    (with-installed (git tar curl gzip autotools-dev
                         pkg-config libtool dh-autoreconf)
      (! "Building universal-ctags...")
      (with-build-dir (tctags "/tmp/ctags/")
        ($ "git clone https://github.com/universal-ctags/ctags.git ."
           ;; FIXME: We could be more precise...
           `("chmod 777 -R %s" ,tctags)
           "./autogen.sh"
           "./configure"
           "make"
           "make install"))
      (with-build-dir (tgtags "/tmp/gtags/")
        (! "Building gtags...")
        ($ `("curl http://tamacom.com/global/global-%s.tar.gz | tar xvz"
             ,global-version))
        (cd `("%sglobal-%s" ,tgtags ,global-version))
        ($ "cp ./gtags.conf /etc/gtags.conf"
           "./configure --with-exuberant-ctags=/usr/local/bin/ctags"
           "make"
           "make install")
        (set-glob-env "GTAGSLABEL" "pygments")))))
