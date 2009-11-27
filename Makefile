PROD = NewtonKeyboard
APP  = NewtonKeyboard.app
VERSION = $(shell defaults read $(shell pwd)/Info CFBundleVersion)

BUILT_RSRC  = NewtonKeyboardView.nib MainWindow.nib
STATIC_RSRC = Info.plist KeyArrowDown.png KeyArrowLeft.png KeyArrowRight.png \
              KeyArrowUp.png KeyCmd.png KeyCmd_Down.png NewtonMP130.png \
              Icon.png Icon-Small.png Default.png

RSRC = $(STATIC_RSRC) $(BUILT_RSRC)
OBJS = main.o UDES.o UDESTables.o NewtonPassword.o NSOFDataTypes.o MNPPipe.o \
       NewtonConnection.o NSOFEncoder.o NewtonInfo.o NewtonKeyboardAppDelegate.o \
       NewtonKeyboardViewController.o SoftKeyboard.o

CC = arm-apple-darwin9-gcc
CPP = arm-apple-darwin9-g++
LD = $(CC)
IBTOOL = /Developer/usr/bin/ibtool
LDID = arm-apple-darwin9-ldid
MD5 = md5
IPHONE = iphone
SSH_PORT = 22

LDFLAGS = -framework Foundation \
          -framework UIKit \
          -framework CoreFoundation \
          -lobjc \
          -bind_at_load \
          -multiply_defined suppress

CFLAGS = -Werror -DIBOutlet='' -DIBAction=void \
         -march=armv6 -mcpu=arm1176jzf-s -fomit-frame-pointer -O3 \
         -include NewtonKeyboard_Prefix.pch
CPPFLAGS := $(CFLAGS)
CFLAGS += -std=c99
BUILDDIR = build/opentoolchain

all: $(PROD) app

$(PROD): $(OBJS)
	$(LD) $(CFLAGS) $(LDFLAGS) -o $(PROD) $^
	$(LDID) -S $(PROD)

%.o: %.m
	$(CC) -c $(CFLAGS) $< -o $@

%.o: Classes/%.m
	$(CC) -c $(CFLAGS) $< -o $@

%.o: Classes/%.mm
	$(CPP) -c $(CPPFLAGS) $< -o $@

%.o: Classes/%.cp
	$(CC) -c $(CPPFLAGS) $< -o $@

%.nib: %.xib
	$(IBTOOL) --errors --warnings --notices --output-format human-readable-text --compile $@ $<

app: $(BUILDDIR)/$(APP)
	
$(BUILDDIR)/$(APP): $(PROD) $(RSRC)
	mkdir -p $(BUILDDIR)/$(APP)
	cp -r $(RSRC) $(BUILDDIR)/$(APP)/
	cp $(PROD) $(BUILDDIR)/$(APP)/
	rm -rf $(BUILDDIR)/$(APP)/.svn $(BUILDDIR)/$(APP)/*/.svn $(BUILDDIR)/$(APP)/.DS_Store $(BUILDDIR)/$(APP)/*/.DS_Store

clean:
	rm -rf $(OBJS) $(BUILT_RSRC) $(PROD)
	rm -rf $(BUILDDIR)

install: app
	scp -r -P $(SSH_PORT) $(BUILDDIR)/$(APP) root@$(IPHONE):/Applications
	ssh -p $(SSH_PORT) $(IPHONE) -l mobile uicache

reinstall: app
	ssh -p $(SSH_PORT) $(IPHONE) rm -f /Applications/$(APP)/$(PROD)
	scp -r -P $(SSH_PORT) $(BUILDDIR)/$(APP)/$(PROD) root@$(IPHONE):/Applications/$(APP)/$(PROD)

reinstall-all: app
	ssh -p $(SSH_PORT) $(IPHONE) rm -f /Applications/$(APP)/$(PROD)
	scp -r -P $(SSH_PORT) $(BUILDDIR)/$(APP) root@$(IPHONE):/Applications

uninstall:
	ssh -p $(SSH_PORT) $(IPHONE) rm -r /Applications/$(APP)
	ssh -p $(SSH_PORT) $(IPHONE) -l mobile uicache

dist:app
	mkdir -p $(BUILDDIR)/$(PROD)/{Applications,DEBIAN}
	cp -r $(BUILDDIR)/$(APP) $(BUILDDIR)/$(PROD)/Applications/
	rm -f $(BUILDDIR)/$(PROD)/Applications/$(APP)/*.{dsk,img,rom,ROM}
	sed 's/\$$VERSION/$(VERSION)/g' apt-control > $(BUILDDIR)/$(PROD)/DEBIAN/control
	echo Installed-Size: `du -ck $(BUILDDIR)/$(PROD) | tail -1 | cut -f 1` >> $(BUILDDIR)/$(PROD)/DEBIAN/control
	COPYFILE_DISABLE="" COPY_EXTENDED_ATTRIBUTES_DISABLE="" dpkg-deb -b $(BUILDDIR)/$(PROD)
