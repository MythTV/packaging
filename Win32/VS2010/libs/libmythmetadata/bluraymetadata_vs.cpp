#include <QHash>

#include "bluraymetadata.h"
#include "mythdirs.h"

BlurayMetadata::BlurayMetadata(const QString path) :
    m_bdnav(NULL),               m_metadata(NULL),
    m_title(QString()),          m_alttitle(QString()),
    m_language(QString()),       m_discnumber(0),
    m_disctotal(0),              m_path(path),
    m_images(QStringList()),     m_topMenuSupported(false),
    m_firstPlaySupported(false), m_numHDMVTitles(0),
    m_numBDJTitles(0),           m_numUnsupportedTitles(0),
    m_aacsDetected(false),       m_libaacsDetected(false),
    m_aacsHandled(false),        m_bdplusDetected(false),
    m_libbdplusDetected(false),  m_bdplusHandled(false)
{
}

BlurayMetadata::~BlurayMetadata()
{
}

bool BlurayMetadata::OpenDisc(void)
{
    return false;
}

bool BlurayMetadata::ParseDisc(void)
{
    return false;
}

void BlurayMetadata::toMap(MetadataMap &metadataMap)
{
    metadataMap["title"     ] = m_title;
    metadataMap["alttitle"  ] = m_alttitle;
    metadataMap["language"  ] = m_language;

    metadataMap["discnumber"] = QString::number(m_discnumber);
    metadataMap["disctotal" ] = QString::number(m_disctotal);
    metadataMap["discseries"] = QObject::tr("%1 of %2")
                                    .arg(m_discnumber)
                                    .arg(m_disctotal);

    metadataMap["numtitles" ] = m_titles.count();
    metadataMap["numthumbs" ] = m_images.count();
}
