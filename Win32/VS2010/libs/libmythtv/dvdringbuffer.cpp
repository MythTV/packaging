#include <unistd.h>
#include <stdlib.h>

#include "mythconfig.h"

#include "dvdringbuffer.h"
#include "mythcontext.h"
#include "mythmediamonitor.h"
#include "iso639.h"

#include "mythdvdplayer.h"
#include "compat.h"
#include "mythuihelper.h"

#define LOC      QString("DVDRB: ")
#define LOC_ERR  QString("DVDRB, Error: ")
#define LOC_WARN QString("DVDRB, Warning: ")

#define IncrementButtonVersion \
    if (++m_buttonVersion > 1024) \
        m_buttonVersion = 1;

static const char *dvdnav_menu_table[] =
{
    NULL,
    NULL,
    "Title",
    "Root",
    "Subpicture",
    "Audio",
    "Angle",
    "Part",
};

dvdnav_status_t dvdnav_part_play(dvdnav_t *self, int32_t title, int32_t part)
{
    return 0;
}

DVDRingBuffer::DVDRingBuffer(const QString &lfilename) :
    m_dvdnav(NULL),     m_dvdBlockReadBuf(NULL),
    m_dvdBlockRPos(0),  m_dvdBlockWPos(0),
    m_pgLength(0),      m_pgcLength(0),
    m_cellStart(0),     m_cellChanged(false),
    m_pgcLengthChanged(false), m_pgStart(0),
    m_currentpos(0),
    m_lastNav(NULL),    m_part(0), m_lastPart(0),
    m_title(0),         m_lastTitle(0),   m_playerWait(false),
    m_titleParts(0),    m_gotStop(false), m_currentAngle(0),
    m_currentTitleAngleCount(0), m_newSequence(false),
    m_still(0), m_lastStill(0),
    m_audioStreamsChanged(false),
    m_dvdWaiting(false),
    m_titleLength(0),

    m_skipstillorwait(true),
    m_cellstartPos(0), m_buttonSelected(false),
    m_buttonExists(false), m_cellid(0),
    m_lastcellid(0), m_vobid(0),
    m_lastvobid(0), m_cellRepeated(false),

    m_curAudioTrack(0),
    m_curSubtitleTrack(0),
    m_autoselectsubtitle(true),
    m_dvdname(NULL), m_serialnumber(NULL),
    m_seeking(false), m_seektime(0),
    m_currentTime(0),
    m_parent(NULL),

    // Menu/buttons
    m_inMenu(false), m_buttonVersion(1), m_buttonStreamID(0),
    m_hl_button(0, 0, 0, 0), m_menuSpuPkt(0), m_menuBuflength(0),
    RingBuffer( kRingBuffer_DVD )
{
    
}

DVDRingBuffer::~DVDRingBuffer()
{
}

void DVDRingBuffer::CloseDVD(void)
{
}

bool DVDRingBuffer::IsBookmarkAllowed( void )
{
    return false;
}

long long DVDRingBuffer::Seek(long long pos, int whence, bool has_lock)
{
    return -1;
}

long long DVDRingBuffer::NormalSeek(long long time)
{
    return Seek(time);
}

long long DVDRingBuffer::Seek(long long time)
{
    return -1;
}

void DVDRingBuffer::GetDescForPos(QString &desc)
{
}

bool DVDRingBuffer::OpenFile(const QString &lfilename, uint retry_ms)
{
    return false;
}

bool DVDRingBuffer::StartFromBeginning(void)
{
    return false;

}

/** \brief returns current position in the PGC.
 */
long long DVDRingBuffer::GetReadPosition(void) const
{
    return 0;
}

void DVDRingBuffer::WaitForPlayer(void)
{
}

int DVDRingBuffer::safe_read(void *data, uint sz)
{
    return 0;
}

bool DVDRingBuffer::nextTrack(void)
{
    return false;
}

void DVDRingBuffer::prevTrack(void)
{
}

/** \brief get the total time of the title in seconds
 * 90000 ticks = 1 sec
 */
uint DVDRingBuffer::GetTotalTimeOfTitle(void)
{
    return m_pgcLength / 90000;
}

/** \brief get the start of the cell in seconds
 */
uint DVDRingBuffer::GetCellStart(void)
{
    return m_cellStart / 90000;
}

/** \brief check if dvd cell has changed
 */
bool DVDRingBuffer::CellChanged(void)
{
    return false;
}

/** \brief check if pgc length has changed
 */
bool DVDRingBuffer::PGCLengthChanged(void)
{
    return false;
}

void DVDRingBuffer::SkipStillFrame(void)
{
}

void DVDRingBuffer::WaitSkip(void)
{
}

/** \brief jump to a dvd root or chapter menu
 */
bool DVDRingBuffer::GoToMenu(const QString str)
{
    return false;
}

void DVDRingBuffer::GoToNextProgram(void)
{
}

void DVDRingBuffer::GoToPreviousProgram(void)
{
}

bool DVDRingBuffer::HandleAction(const QStringList &actions, int64_t pts)
{
    return false;
}

void DVDRingBuffer::MoveButtonLeft(void)
{
}

void DVDRingBuffer::MoveButtonRight(void)
{
}

void DVDRingBuffer::MoveButtonUp(void)
{
}

void DVDRingBuffer::MoveButtonDown(void)
{
}

/** \brief action taken when a dvd menu button is selected
 */
void DVDRingBuffer::ActivateButton(void)
{
}

/** \brief get SPU pkt from dvd menu subtitle stream
 */
void DVDRingBuffer::GetMenuSPUPkt(uint8_t *buf, int buf_size, int stream_id)
{
}

/** \brief returns dvd menu button information if available.
 * used by NVP::DisplayDVDButton
 */
AVSubtitle *DVDRingBuffer::GetMenuSubtitle(uint &version)
{
    return NULL;
}


void DVDRingBuffer::ReleaseMenuButton(void)
{
}

/** \brief get coordinates of highlighted button
 */
QRect DVDRingBuffer::GetButtonCoords(void)
{
    QRect rect(0,0,0,0);
    return rect;
}

/** \brief generate dvd subtitle bitmap or dvd menu bitmap.
 * code obtained from ffmpeg project
 */
bool DVDRingBuffer::DecodeSubtitles(AVSubtitle *sub, int *gotSubtitles,
                                    const uint8_t *spu_pkt, int buf_size)
{
    return false;
}

/** \brief update the dvd menu button parameters
 * when a user changes the dvd menu button position
 */
bool DVDRingBuffer::DVDButtonUpdate(bool b_mode)
{
    return false;
}

/** \brief clears the dvd menu button structures
 */
void DVDRingBuffer::ClearMenuButton(void)
{
}

/** \brief clears the menu SPU pkt and parameters.
 * necessary action during dvd menu changes
 */
void DVDRingBuffer::ClearMenuSPUParameters(void)
{
}

int DVDRingBuffer::NumMenuButtons(void) const
{
    return 0;
}

/** \brief get the audio language from the dvd
 */
uint DVDRingBuffer::GetAudioLanguage(int id)
{
    return 0;
}

/** \brief get real dvd track audio number
  * \param key stream_id
*/
int DVDRingBuffer::GetAudioTrackNum(uint stream_id)
{
    return 0;
}

/** \brief get the subtitle language from the dvd
 */
uint DVDRingBuffer::GetSubtitleLanguage(int id)
{
    return 0;
}

/** \brief converts the subtitle/audio lang code to iso639.
 */
uint DVDRingBuffer::ConvertLangCode(uint16_t code)
{
    return 0;
}

/** \brief determines the default dvd menu button to
 * show when you initially access the dvd menu.
 */
void DVDRingBuffer::SelectDefaultButton(void)
{
}

/** \brief set the dvd subtitle/audio track used
 *  \param type    currently kTrackTypeSubtitle or kTrackTypeAudio
 *  \param trackNo if -1 then autoselect the track num from the dvd IFO
 */
void DVDRingBuffer::SetTrack(uint type, int trackNo)
{
}

/** \brief get the track the dvd should be playing.
 * can either be set by the user using DVDRingBuffer::SetTrack
 * or determined from the dvd IFO.
 * \param type: use either kTrackTypeSubtitle or kTrackTypeAudio
 */
int DVDRingBuffer::GetTrack(uint type)
{
    return 0;
}

int  DVDRingBuffer::GetAudioTrackType(uint stream_id)
{
	return 0;
}

uint8_t DVDRingBuffer::GetNumAudioChannels(int id)
{
    return 0;
}

/** \brief Get the dvd title and serial num
 */
bool DVDRingBuffer::GetNameAndSerialNum(QString& _name, QString& _serial)
{
    return false;
}

/** \brief used by DecoderBase for the total frame number calculation
 * for position map support and ffw/rew.
 * FPS for a dvd is determined by AFD::normalized_fps
 * * dvdnav_get_video_format: 0 - NTSC, 1 - PAL
 */
double DVDRingBuffer::GetFrameRate(void)
{
    return 0;
}

/** \brief set dvd speed. uses the DVDDriveSpeed Setting from the settings
 *  table
 */
void DVDRingBuffer::SetDVDSpeed(void)
{
}

/** \brief set dvd speed.
 */
void DVDRingBuffer::SetDVDSpeed(int speed)
{
}

/**\brief returns seconds left in the title
 */
uint DVDRingBuffer::TitleTimeLeft(void)
{
    return 0;
}

/** \brief converts palette values from YUV to RGB
 */
void DVDRingBuffer::guess_palette(uint32_t *rgba_palette,uint8_t *palette,
                                        uint8_t *alpha)
{
}

/** \brief decodes the bitmap from the subtitle packet.
 *         copied from ffmpeg's dvdsubdec.c.
 */
int DVDRingBuffer::decode_rle(uint8_t *bitmap, int linesize, int w, int h,
                                  const uint8_t *buf, int nibble_offset, int buf_size)
{
    return 0;
}

/** copied from ffmpeg's dvdsubdec.c
 */
int DVDRingBuffer::get_nibble(const uint8_t *buf, int nibble_offset)
{
    return 0;
}

/**
 * \brief obtained from ffmpeg dvdsubdec.c
 * used to find smallest bounded rectangle
 */
int DVDRingBuffer::is_transp(const uint8_t *buf, int pitch, int n,
                     const uint8_t *transp_color)
{
    return 0;
}

/**
 * \brief obtained from ffmpeg dvdsubdec.c
 * used to find smallest bounded rect.
 * helps prevent jerky picture during subtitle creation
 */
int DVDRingBuffer::find_smallest_bounding_rectangle(AVSubtitle *s)
{
    return 0;
}

bool DVDRingBuffer::SwitchAngle(uint angle)
{
    return false;
}

bool DVDRingBuffer::NewSequence(bool new_sequence)
{
    return false;
}

void DVDRingBuffer::GetChapterTimes(QList<long long> &times)
{
}

bool DVDRingBuffer::playTrack(int track)
{
    return false;
}

DVDInfo::DVDInfo(const QString &filename)
{
}

DVDInfo::~DVDInfo(void)
{
}

bool DVDInfo::GetNameAndSerialNum(QString &name, QString &serialnum)
{
    return false;
}
