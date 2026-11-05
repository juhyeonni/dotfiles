-- ==============================================
--  Input Source
-- ==============================================
-- Karabiner turns physical keys into f19/f17 and this file switches the input source.
-- Switching directly with Karabiner's select_input_source was tried and reverted: it rides a
-- deprecated Carbon API that is unreliable for CJK sources with an input_mode_id (Korean,
-- Japanese). Do not repeat it.
-- https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/select-input-source/
-- https://github.com/pqrs-org/Karabiner-Elements/issues/1602
local inputEnglish = "com.apple.keylayout.ABC"
local inputKorean = "com.apple.inputmethod.Korean.2SetKorean"
local inputJapanese = "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"

-- ==============================================
--  Toggle
-- ==============================================
function eng_kor_toggle_with_capslock()
	local inputSource = hs.keycodes.currentSourceID()
	if inputSource == inputEnglish then
		hs.keycodes.currentSourceID(inputKorean)
	elseif inputSource == inputKorean then
		hs.keycodes.currentSourceID(inputEnglish)
	else
		hs.keycodes.currentSourceID(inputEnglish)
	end
end

function jpn_kor_toggle_with_right_option()
	local inputSource = hs.keycodes.currentSourceID()
	if inputSource == inputKorean then
		hs.keycodes.currentSourceID(inputJapanese)
	elseif inputSource == inputJapanese then
		hs.keycodes.currentSourceID(inputKorean)
	else
		hs.keycodes.currentSourceID(inputJapanese)
	end
end

-- ==============================================
--  Korean IME handling for Ghostty keys
-- ==============================================
-- Force a switch to English on the keys below, so typing after them (the herdr prefix, the
-- workspace-jump query) is English. Ghostty already sends the keys themselves by physical
-- position (ctrl+key_a, alt+key_s), so they work under the Korean IME without this.
-- The event passes through untouched (return false), and the switch runs on the next run loop
-- turn: switching inside the tap holds the keystroke until the input source has changed.
--
-- herdr's switch_ascii_input_source_in_prefix only switches to ASCII *inside* prefix mode,
-- so it covers neither entering the prefix (ctrl+a) nor prefix-less direct bindings (alt+s).
-- Those two gaps are filled here.
--
-- Karabiner claims the right option as f17, so any alt reaching this point is the left one.
local GHOSTTY_BUNDLE_ID = "com.mitchellh.ghostty"
local forceEnglishKeys = {
	{ code = 0, mods = { "ctrl" } }, -- kVK_ANSI_A · ctrl+a : herdr prefix
	{ code = 1, mods = { "alt" } }, -- kVK_ANSI_S · alt+s  : herdr workspace-jump
}

local ghostty_force_english = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
	local code, flags = e:getKeyCode(), e:getFlags()
	for _, k in ipairs(forceEnglishKeys) do
		-- This runs on every keystroke, so compare the cheap key first and only query the app on a match.
		if code == k.code and flags:containExactly(k.mods) then
			hs.timer.doAfter(0, function()
				if hs.application.frontmostApplication():bundleID() ~= GHOSTTY_BUNDLE_ID then
					return
				end
				if hs.keycodes.currentSourceID() ~= inputEnglish then
					hs.keycodes.currentSourceID(inputEnglish)
				end
			end)
			break
		end
	end
	return false
end)
ghostty_force_english:start()

-- ==============================================
--  Keybindings
-- ==============================================
-- f19/f17 are keys remapped by simple_modifications in karabiner.json.
-- (caps_lock -> f19, right_option -> f17)
-- reference: https://www.hammerspoon.org/docs/hs.hotkey.html
hs.hotkey.bind({}, "f19", eng_kor_toggle_with_capslock)
hs.hotkey.bind({}, "f17", jpn_kor_toggle_with_right_option)
hs.hotkey.bind({ "cmd", "shift" }, "space", jpn_kor_toggle_with_right_option)
