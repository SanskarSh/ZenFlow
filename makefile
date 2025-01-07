FLUTTER = fvm flutter

run:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs && ${FLUTTER} run

clean:
	${FLUTTER} clean

get: 
	${FLUTTER} pub get

build-android:
	$(FLUTTER) build apk

generate:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

prepare:
	$(FLUTTER) clean && $(FLUTTER) pub get && $(FLUTTER) pub run build_runner build --delete-conflicting-outputs