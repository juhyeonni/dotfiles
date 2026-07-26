-- key bindding reference --> https://www.hammerspoon.org/docs/hs.hotkey.html
local inputEnglish = "com.apple.keylayout.ABC"
local inputKorean = "com.apple.inputmethod.Korean.2SetKorean"
local inputJapanese = "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"

-- key mapping for multi language

-- local inputEnglish = "com.apple.keylayout.ABC"
-- local inputKorean = "com.apple.inputmethod.Korean.2SetKorean"
-- local inputJapanese = "com.apple.inputmethod.Kotoeri.Japanese"

-- function eng_kor_toggle_with_capslock()
--   local inputSource = hs.keycodes.currentSourceID()
--   if (inputSource == inputEnglish) then
--     hs.keycodes.currentSourceID(inputKorean)

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

-- cmd + shift + space key
hs.hotkey.bind({ "cmd", "shift" }, "space", jpn_kor_toggle_with_right_option)
