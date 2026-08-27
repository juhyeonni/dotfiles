-- ==============================================
--  Input Source
-- ==============================================
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
--  Ghostty 키 한글 대응
-- ==============================================
-- 한글 입력 중에도 herdr 키가 먹도록, 아래 키를 누르면 영문으로 강제 전환한다.
-- 이벤트 자체는 그대로 통과시킨다(return false).
--
-- herdr 의 switch_ascii_input_source_in_prefix 는 prefix 모드 '안에서만' ASCII 로
-- 바꾸므로, prefix 진입 자체(ctrl+a)와 prefix 없는 직접 바인딩(alt+s)은 못 덮는다.
-- 그 두 구멍을 여기서 메운다.
--
-- 오른쪽 option 은 karabiner 가 f17 로 가져가므로, 여기 도달하는 alt 는 항상 왼쪽이다.
local GHOSTTY_BUNDLE_ID = "com.mitchellh.ghostty"
local forceEnglishKeys = {
	{ code = 0, mods = { "ctrl" } }, -- kVK_ANSI_A · ctrl+a : herdr prefix
	{ code = 1, mods = { "alt" } }, -- kVK_ANSI_S · alt+s  : herdr workspace-jump
}

local ghostty_force_english = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
	local code, flags = e:getKeyCode(), e:getFlags()
	for _, k in ipairs(forceEnglishKeys) do
		-- 매 키 입력마다 도는 경로라, 값싼 키 비교를 먼저 하고 앱 조회는 매치될 때만 한다.
		if code == k.code and flags:containExactly(k.mods) then
			if hs.application.frontmostApplication():bundleID() == GHOSTTY_BUNDLE_ID then
				hs.keycodes.currentSourceID(inputEnglish)
			end
			break
		end
	end
	return false
end)
ghostty_force_english:start()

-- ==============================================
--  Keybindings
-- ==============================================
-- f19/f17 은 karabiner.json 의 simple_modifications 로 리맵된 키다.
-- (caps_lock -> f19, right_option -> f17)
-- reference: https://www.hammerspoon.org/docs/hs.hotkey.html
hs.hotkey.bind({}, "f19", eng_kor_toggle_with_capslock)
hs.hotkey.bind({}, "f17", jpn_kor_toggle_with_right_option)
hs.hotkey.bind({ "cmd", "shift" }, "space", jpn_kor_toggle_with_right_option)
