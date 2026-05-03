.PHONY: build dmg clean run reset

build:
	@bash Scripts/build.sh

dmg: build
	@bash Scripts/package-dmg.sh

reset:
	@echo "-> Killing KeyMacro..."
	@pkill KeyMacro 2>/dev/null || true
	@echo "-> Deleting app data..."
	@rm -rf ~/Library/Application\ Support/KeyMacro
	@echo "-> Revoking Accessibility permission..."
	@tccutil reset Accessibility io.velaris.KeyMacro 2>/dev/null || true
	@echo "-> Reset complete."

run: reset build
	@open build/KeyMacro.app

clean:
	rm -rf build/
