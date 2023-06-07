#include <QImage>
#include <QDir>
#include <QCoreApplication>

#include "bdnav/mpls_parse.h"
#include "bdnav/meta_parse.h"
#include "bdnav/navigation.h"
#include "bdnav/bdparse.h"
#include "decoders/overlay.h"

#include "mythmainwindow.h"
#include "mythevent.h"
#include "iso639.h"
#include "bdringbuffer.h"
#include "mythcorecontext.h"
#include "mythlocale.h"
#include "mythdirs.h"
#include "bluray.h"
#include "tv.h" // for actions
#include "mythiowrapper.h"

#define LOC      QString("BDRingBuf: ")
#define LOC_WARN QString("BDRingBuf Warning: ")
#define LOC_ERR  QString("BDRingBuf Error: ")

static void HandleOverlayCallback(void *data, const bd_overlay_s *const overlay)
{
}

static void file_opened_callback(void* bdr)
{
}

BDRingBuffer::BDRingBuffer(const QString &lfilename)
  : bdnav(NULL), m_isHDMVNavigation(false), m_tryHDMVNavigation(false),
    m_topMenuSupported(false), m_firstPlaySupported(false),
    m_numTitles(0), m_titleChanged(false), m_playerWait(false),
    m_ignorePlayerWait(true),
    m_stillTime(0), m_stillMode(BLURAY_STILL_NONE),
    m_infoLock(QMutex::Recursive), m_mainThread(NULL),
    RingBuffer( kRingBuffer_BD )
{
}

BDRingBuffer::~BDRingBuffer()
{
}

void BDRingBuffer::close(void)
{
}

long long BDRingBuffer::Seek(long long pos, int whence, bool has_lock)
{
    return -1;
}

uint64_t BDRingBuffer::Seek(uint64_t pos)
{
    return 0;
}

void BDRingBuffer::GetDescForPos(QString &desc)
{
}

bool BDRingBuffer::HandleAction(const QStringList &actions, int64_t pts)
{
    return false;
}

void BDRingBuffer::ProgressUpdate(void)
{
}

bool BDRingBuffer::OpenFile(const QString &lfilename, uint retry_ms)
{
    return false;
}

long long BDRingBuffer::GetReadPosition(void) const
{
    return 0;
}

uint32_t BDRingBuffer::GetNumChapters(void)
{
    return 0;
}

uint32_t BDRingBuffer::GetCurrentChapter(void)
{
    return 0;
}

uint64_t BDRingBuffer::GetChapterStartTime(uint32_t chapter)
{
    return 0;
}

uint64_t BDRingBuffer::GetChapterStartFrame(uint32_t chapter)
{
    return 0;
}

int BDRingBuffer::GetCurrentTitle(void)
{
    return -1;
}

int BDRingBuffer::GetTitleDuration(int title)
{
    return 0;
}

bool BDRingBuffer::SwitchTitle(uint32_t index)
{
    return false;
}

bool BDRingBuffer::SwitchPlaylist(uint32_t index)
{
    return false;
}

BLURAY_TITLE_INFO* BDRingBuffer::GetTitleInfo(uint32_t index)
{
    return NULL;
}

BLURAY_TITLE_INFO* BDRingBuffer::GetPlaylistInfo(uint32_t index)
{
    return NULL;
}

bool BDRingBuffer::UpdateTitleInfo(void)
{
    return false;
}

bool BDRingBuffer::TitleChanged(void)
{
    return false;
}

bool BDRingBuffer::SwitchAngle(uint angle)
{
    return false;
}

uint64_t BDRingBuffer::GetTotalReadPosition(void)
{
    return 0;
}

int BDRingBuffer::safe_read(void *data, uint sz)
{
    return 0;
}

double BDRingBuffer::GetFrameRate(void)
{
    return 0;
}

int BDRingBuffer::GetAudioLanguage(uint streamID)
{
    return 0;
}

int BDRingBuffer::GetSubtitleLanguage(uint streamID)
{
    return 0;
}

void BDRingBuffer::PressButton(int32_t key, int64_t pts)
{
}

void BDRingBuffer::ClickButton(int64_t pts, uint16_t x, uint16_t y)
{
}

/** \brief jump to a Blu-ray root or popup menu
 */
bool BDRingBuffer::GoToMenu(const QString str, int64_t pts)
{
    return false;
}

bool BDRingBuffer::HandleBDEvents(void)
{
    return false;
}

void BDRingBuffer::HandleBDEvent(BD_EVENT &ev)
{
}

bool BDRingBuffer::IsInStillFrame(void) const
{
    return false;
}

void BDRingBuffer::WaitForPlayer(void)
{
}

bool BDRingBuffer::StartFromBeginning(void)
{
    return true;
}

bool BDRingBuffer::GetNameAndSerialNum(QString &name, QString &serial)
{
    return false;
}

void BDRingBuffer::ClearOverlays(void)
{
}

BDOverlay* BDRingBuffer::GetOverlay(void)
{
    return NULL;
}

void BDRingBuffer::SubmitOverlay(const bd_overlay_s * const overlay)
{
}
