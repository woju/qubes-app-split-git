all:
install:
	install -d $(DESTDIR)/usr/bin
	install -t $(DESTDIR)/usr/bin -m 755 git-remote-qrexec
	install -d $(DESTDIR)/etc/qubes-rpc
	install -t $(DESTDIR)/etc/qubes-rpc -m 755 qubes-rpc/*
