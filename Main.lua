require "import"
import "android.widget.*"
import "android.view.*"
import "android.media.MediaPlayer"
import "java.io.File"
import "android.os.Environment"

activity.setTitle("Accessible Music Player")

mediaPlayer = MediaPlayer()

rootFolder = tostring(Environment.getExternalStorageDirectory())

audioList = {}

function scanFolder(path)

  local dir = File(path)

  if not dir.exists() then
    return
  end

  local files = dir.listFiles()

  if files == nil then
    return
  end

  for i = 0, #files - 1 do

    local file = files[i]

    if file then

      if file.isDirectory() then

        scanFolder(tostring(file.getAbsolutePath()))

      elseif file.isFile() then

        local name = tostring(file.getName()):lower()

        if name:find("%.mp3$")
        or name:find("%.wav$")
        or name:find("%.m4a$")
        or name:find("%.ogg$") then

          table.insert(audioList, tostring(file.getAbsolutePath()))

        end
      end
    end
  end
end

showScanToast = Toast.makeText(activity,"Scanning audio files...",Toast.LENGTH_LONG)
showScanToast.show()

scanFolder(rootFolder)

layout = {
  LinearLayout,
  orientation = "vertical",
  padding = "16dp",

  {
    TextView,
    text = "Accessible Music Player",
    textSize = "22sp",
    gravity = "center",
    layout_width = "match_parent",
  },

  {
    TextView,
    text = "Developer: Muzamil",
    textSize = "16sp",
    gravity = "center",
    layout_width = "match_parent",
  },

  {
    TextView,
    id = "songCount",
    text = "Songs found: "..tostring(#audioList),
    textSize = "16sp",
    layout_width = "match_parent",
  },

  {
    Button,
    id = "playAllBtn",
    text = "Play All",
    layout_width = "match_parent",
  },

  {
    LinearLayout,
    id = "controlsLayout",
    orientation = "vertical",
    visibility = 8,

    {
      Button,
      id = "pauseBtn",
      text = "Pause / Resume",
      layout_width = "match_parent",
    },

    {
      Button,
      id = "nextBtn",
      text = "Next",
      layout_width = "match_parent",
    },

    {
      Button,
      id = "prevBtn",
      text = "Previous",
      layout_width = "match_parent",
    },

    {
      Button,
      id = "stopBtn",
      text = "Stop",
      layout_width = "match_parent",
    },
  },
}

activity.setContentView(loadlayout(layout))

currentIndex = 1
isStopped = false

function showMessage(msg)
  Toast.makeText(activity,msg,Toast.LENGTH_SHORT).show()
end

function playAudio(index)

  if #audioList == 0 then
    showMessage("No audio files found")
    return
  end

  if index > #audioList then
    index = 1
  end

  if index < 1 then
    index = #audioList
  end

  currentIndex = index

  local path = audioList[currentIndex]

  local file = File(path)

  if not file.exists() then
    showMessage("Missing file")
    return
  end

  pcall(function()
    mediaPlayer.reset()
  end)

  local ok, err = pcall(function()

    mediaPlayer.setDataSource(path)

    mediaPlayer.prepare()

    mediaPlayer.start()

  end)

  if not ok then

    print(tostring(err))

    showMessage("Playback error")

    return
  end

  showMessage("Playing: "..file.getName())

end

mediaPlayer.setOnCompletionListener{

  onCompletion = function(mp)

    if isStopped then
      return
    end

    local nextIndex = currentIndex + 1

    if nextIndex > #audioList then
      nextIndex = 1
    end

    currentIndex = nextIndex

    playAudio(currentIndex)

  end
}

playAllBtn.onClick = function()

  if #audioList == 0 then
    showMessage("No songs available")
    return
  end

  isStopped = false

  currentIndex = 1

  playAllBtn.setVisibility(8)

  controlsLayout.setVisibility(0)

  playAudio(currentIndex)

end

pauseBtn.onClick = function()

  pcall(function()

    if mediaPlayer.isPlaying() then

      mediaPlayer.pause()

      showMessage("Paused")

    else

      mediaPlayer.start()

      showMessage("Resumed")

    end

  end)

end

nextBtn.onClick = function()

  local nextIndex = currentIndex + 1

  if nextIndex > #audioList then
    nextIndex = 1
  end

  currentIndex = nextIndex

  playAudio(currentIndex)

end

prevBtn.onClick = function()

  local prevIndex = currentIndex - 1

  if prevIndex < 1 then
    prevIndex = #audioList
  end

  currentIndex = prevIndex

  playAudio(currentIndex)

end

stopBtn.onClick = function()

  isStopped = true

  pcall(function()

    mediaPlayer.stop()

    mediaPlayer.reset()

  end)

  playAllBtn.setVisibility(0)

  controlsLayout.setVisibility(8)

  showMessage("Stopped")

end

function onDestroy()

  pcall(function()

    mediaPlayer.release()

  end)

end