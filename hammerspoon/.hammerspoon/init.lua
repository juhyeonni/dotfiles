-- key mapping for vim
-- Convert input soruce as English and sends 'escape' if inputSource is not English.
-- Sends 'escape' if inputSource is English.
-- key bindding reference --> https://www.hammerspoon.org/docs/hs.hotkey.html
local inputEnglish = "com.apple.keylayout.ABC"
local inputKorean = "com.apple.inputmethod.Korean.2SetKorean"
local inputJapanese = "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"

function eng_kor_toggle_with_capslock()
	local inputSource = hs.keycodes.currentSourceID()
	if inputSource == inputEnglish then
		hs.keycodes.currentSourceID(inputKorean)
	elseif inputSource == inputKorean then
		hs.keycodes.currentSourceID(inputEnglish)
	else
		hs.keycodes.currentSourceID(inputEnglish)
	end
	-- hs.eventtap.keyStroke({}, '')
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
	-- hs.eventtap.keyStroke({}, '')
end

--shortcut
hs.hotkey.bind({}, "f19", eng_kor_toggle_with_capslock)

-- right option key
hs.hotkey.bind({}, "f17", jpn_kor_toggle_with_right_option)

-- cmd + shift + space key
hs.hotkey.bind({ "cmd", "shift" }, "space", jpn_kor_toggle_with_right_option)
