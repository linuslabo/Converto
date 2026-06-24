#!/usr/bin/env python3
"""Generate Converto/Localizable.xcstrings with translations."""

import json
from pathlib import Path

LANGUAGES = [
    "en", "es", "fr", "de", "it", "pt-BR", "pt-PT", "ja", "ko",
    "zh-Hans", "zh-Hant", "ru", "ar", "nl", "pl", "tr", "hi", "id", "uk", "sv",
]

# key -> { lang -> value }
STRINGS = {
    "app_name": {
        "en": "Converto",
        "es": "Converto", "fr": "Converto", "de": "Converto", "it": "Converto",
        "pt-BR": "Converto", "pt-PT": "Converto", "ja": "Converto", "ko": "Converto",
        "zh-Hans": "Converto", "zh-Hant": "Converto", "ru": "Converto", "ar": "كونفيرتو",
        "nl": "Converto", "pl": "Converto", "tr": "Converto", "hi": "Converto",
        "id": "Converto", "uk": "Converto", "sv": "Converto",
    },
    "formats_menu": {
        "en": "Formats…", "es": "Formatos…", "fr": "Formats…", "de": "Formate…",
        "it": "Formati…", "pt-BR": "Formatos…", "pt-PT": "Formatos…", "ja": "形式…",
        "ko": "형식…", "zh-Hans": "格式…", "zh-Hant": "格式…", "ru": "Форматы…",
        "ar": "التنسيقات…", "nl": "Formaten…", "pl": "Formaty…", "tr": "Biçimler…",
        "hi": "प्रारूप…", "id": "Format…", "uk": "Формати…", "sv": "Format…",
    },
    "drop_images_here": {
        "en": "Drop images here", "es": "Suelta las imágenes aquí", "fr": "Déposez les images ici",
        "de": "Bilder hier ablegen", "it": "Trascina le immagini qui", "pt-BR": "Solte as imagens aqui",
        "pt-PT": "Largue as imagens aqui", "ja": "ここに画像をドロップ", "ko": "여기에 이미지를 놓으세요",
        "zh-Hans": "将图片拖放到此处", "zh-Hant": "將圖片拖放到此處", "ru": "Перетащите изображения сюда",
        "ar": "أسقط الصور هنا", "nl": "Sleep afbeeldingen hierheen", "pl": "Upuść obrazy tutaj",
        "tr": "Görselleri buraya bırakın", "hi": "छवियों को यहाँ छोड़ें", "id": "Letakkan gambar di sini",
        "uk": "Перетягніть зображення сюди", "sv": "Släpp bilder här",
    },
    "or_click_to_browse": {
        "en": "or click to browse", "es": "o haz clic para buscar", "fr": "ou cliquez pour parcourir",
        "de": "oder klicken zum Durchsuchen", "it": "oppure clicca per sfogliare",
        "pt-BR": "ou clique para procurar", "pt-PT": "ou clique para procurar",
        "ja": "またはクリックして選択", "ko": "또는 클릭하여 찾아보기",
        "zh-Hans": "或点击浏览", "zh-Hant": "或點擊瀏覽", "ru": "или нажмите для выбора",
        "ar": "أو انقر للتصفح", "nl": "of klik om te bladeren", "pl": "lub kliknij, aby wybrać",
        "tr": "veya göz atmak için tıklayın", "hi": "या ब्राउज़ करने के लिए क्लिक करें",
        "id": "atau klik untuk menelusuri", "uk": "або натисніть для вибору", "sv": "eller klicka för att bläddra",
    },
    "no_images_added": {
        "en": "No images added yet", "es": "Aún no hay imágenes", "fr": "Aucune image ajoutée",
        "de": "Noch keine Bilder hinzugefügt", "it": "Nessuna immagine aggiunta",
        "pt-BR": "Nenhuma imagem adicionada", "pt-PT": "Nenhuma imagem adicionada",
        "ja": "画像がまだありません", "ko": "추가된 이미지가 없습니다",
        "zh-Hans": "尚未添加图片", "zh-Hant": "尚未加入圖片", "ru": "Изображения ещё не добавлены",
        "ar": "لم تُضف صور بعد", "nl": "Nog geen afbeeldingen toegevoegd", "pl": "Nie dodano jeszcze obrazów",
        "tr": "Henüz görsel eklenmedi", "hi": "अभी तक कोई छवि नहीं जोड़ी गई",
        "id": "Belum ada gambar", "uk": "Зображення ще не додано", "sv": "Inga bilder tillagda än",
    },
    "clear": {
        "en": "Clear", "es": "Borrar", "fr": "Effacer", "de": "Leeren", "it": "Svuota",
        "pt-BR": "Limpar", "pt-PT": "Limpar", "ja": "クリア", "ko": "지우기",
        "zh-Hans": "清除", "zh-Hant": "清除", "ru": "Очистить", "ar": "مسح",
        "nl": "Wissen", "pl": "Wyczyść", "tr": "Temizle", "hi": "साफ़ करें",
        "id": "Hapus", "uk": "Очистити", "sv": "Rensa",
    },
    "section_output": {
        "en": "Output", "es": "Salida", "fr": "Sortie", "de": "Ausgabe", "it": "Output",
        "pt-BR": "Saída", "pt-PT": "Saída", "ja": "出力", "ko": "출력",
        "zh-Hans": "输出", "zh-Hant": "輸出", "ru": "Вывод", "ar": "الإخراج",
        "nl": "Uitvoer", "pl": "Wyjście", "tr": "Çıktı", "hi": "आउटपुट",
        "id": "Keluaran", "uk": "Вивід", "sv": "Utdata",
    },
    "format": {
        "en": "Format", "es": "Formato", "fr": "Format", "de": "Format", "it": "Formato",
        "pt-BR": "Formato", "pt-PT": "Formato", "ja": "形式", "ko": "형식",
        "zh-Hans": "格式", "zh-Hant": "格式", "ru": "Формат", "ar": "التنسيق",
        "nl": "Formaat", "pl": "Format", "tr": "Biçim", "hi": "प्रारूप",
        "id": "Format", "uk": "Формат", "sv": "Format",
    },
    "folder": {
        "en": "Folder", "es": "Carpeta", "fr": "Dossier", "de": "Ordner", "it": "Cartella",
        "pt-BR": "Pasta", "pt-PT": "Pasta", "ja": "フォルダ", "ko": "폴더",
        "zh-Hans": "文件夹", "zh-Hant": "資料夾", "ru": "Папка", "ar": "المجلد",
        "nl": "Map", "pl": "Folder", "tr": "Klasör", "hi": "फ़ोल्डर",
        "id": "Folder", "uk": "Папка", "sv": "Mapp",
    },
    "same_as_source": {
        "en": "Same as source", "es": "Igual que el origen", "fr": "Comme la source",
        "de": "Wie Quelle", "it": "Come sorgente", "pt-BR": "Igual à origem",
        "pt-PT": "Igual à origem", "ja": "元と同じ", "ko": "원본과 동일",
        "zh-Hans": "与源文件相同", "zh-Hant": "與來源相同", "ru": "Как у источника",
        "ar": "نفس مجلد المصدر", "nl": "Zelfde als bron", "pl": "Jak źródło",
        "tr": "Kaynakla aynı", "hi": "स्रोत जैसा", "id": "Sama dengan sumber",
        "uk": "Як у джерела", "sv": "Samma som källa",
    },
    "choose_folder": {
        "en": "Choose folder…", "es": "Elegir carpeta…", "fr": "Choisir un dossier…",
        "de": "Ordner wählen…", "it": "Scegli cartella…", "pt-BR": "Escolher pasta…",
        "pt-PT": "Escolher pasta…", "ja": "フォルダを選択…", "ko": "폴더 선택…",
        "zh-Hans": "选择文件夹…", "zh-Hant": "選擇資料夾…", "ru": "Выбрать папку…",
        "ar": "اختر مجلدًا…", "nl": "Map kiezen…", "pl": "Wybierz folder…",
        "tr": "Klasör seç…", "hi": "फ़ोल्डर चुनें…", "id": "Pilih folder…",
        "uk": "Вибрати папку…", "sv": "Välj mapp…",
    },
    "no_folder_selected": {
        "en": "No folder selected", "es": "Ninguna carpeta seleccionada",
        "fr": "Aucun dossier sélectionné", "de": "Kein Ordner ausgewählt",
        "it": "Nessuna cartella selezionata", "pt-BR": "Nenhuma pasta selecionada",
        "pt-PT": "Nenhuma pasta selecionada", "ja": "フォルダが未選択",
        "ko": "선택된 폴더 없음", "zh-Hans": "未选择文件夹", "zh-Hant": "未選擇資料夾",
        "ru": "Папка не выбрана", "ar": "لم يُحدد مجلد", "nl": "Geen map geselecteerd",
        "pl": "Nie wybrano folderu", "tr": "Klasör seçilmedi", "hi": "कोई फ़ोल्डर नहीं चुना गया",
        "id": "Tidak ada folder dipilih", "uk": "Папку не вибрано", "sv": "Ingen mapp vald",
    },
    "browse": {
        "en": "Browse…", "es": "Examinar…", "fr": "Parcourir…", "de": "Durchsuchen…",
        "it": "Sfoglia…", "pt-BR": "Procurar…", "pt-PT": "Procurar…", "ja": "参照…",
        "ko": "찾아보기…", "zh-Hans": "浏览…", "zh-Hant": "瀏覽…", "ru": "Обзор…",
        "ar": "استعراض…", "nl": "Bladeren…", "pl": "Przeglądaj…", "tr": "Göz at…",
        "hi": "ब्राउज़…", "id": "Telusuri…", "uk": "Огляд…", "sv": "Bläddra…",
    },
    "section_quality": {
        "en": "Quality", "es": "Calidad", "fr": "Qualité", "de": "Qualität", "it": "Qualità",
        "pt-BR": "Qualidade", "pt-PT": "Qualidade", "ja": "品質", "ko": "품질",
        "zh-Hans": "质量", "zh-Hant": "品質", "ru": "Качество", "ar": "الجودة",
        "nl": "Kwaliteit", "pl": "Jakość", "tr": "Kalite", "hi": "गुणवत्ता",
        "id": "Kualitas", "uk": "Якість", "sv": "Kvalitet",
    },
    "quality_hint": {
        "en": "Maps to ImageMagick -quality. Effect varies by format.",
        "es": "Se asigna a ImageMagick -quality. El efecto varía según el formato.",
        "fr": "Correspond à ImageMagick -quality. L'effet varie selon le format.",
        "de": "Entspricht ImageMagick -quality. Wirkung hängt vom Format ab.",
        "it": "Corrisponde a ImageMagick -quality. L'effetto varia in base al formato.",
        "pt-BR": "Corresponde ao ImageMagick -quality. O efeito varia conforme o formato.",
        "pt-PT": "Corresponde ao ImageMagick -quality. O efeito varia consoante o formato.",
        "ja": "ImageMagick の -quality に対応します。形式によって効果は異なります。",
        "ko": "ImageMagick -quality에 매핑됩니다. 형식에 따라 효과가 다릅니다.",
        "zh-Hans": "对应 ImageMagick 的 -quality。效果因格式而异。",
        "zh-Hant": "對應 ImageMagick 的 -quality。效果因格式而異。",
        "ru": "Соответствует ImageMagick -quality. Эффект зависит от формата.",
        "ar": "يُطبَّق على ImageMagick -quality. يختلف التأثير حسب التنسيق.",
        "nl": "Komt overeen met ImageMagick -quality. Effect verschilt per formaat.",
        "pl": "Odpowiada ImageMagick -quality. Efekt zależy od formatu.",
        "tr": "ImageMagick -quality ile eşlenir. Etki biçime göre değişir.",
        "hi": "ImageMagick -quality से मैप होता है। प्रभाव प्रारूप के अनुसार बदलता है।",
        "id": "Dipetakan ke ImageMagick -quality. Efek bervariasi menurut format.",
        "uk": "Відповідає ImageMagick -quality. Ефект залежить від формату.",
        "sv": "Motsvarar ImageMagick -quality. Effekten varierar med format.",
    },
    "convert": {
        "en": "Convert", "es": "Convertir", "fr": "Convertir", "de": "Konvertieren",
        "it": "Converti", "pt-BR": "Converter", "pt-PT": "Converter", "ja": "変換",
        "ko": "변환", "zh-Hans": "转换", "zh-Hant": "轉換", "ru": "Конвертировать",
        "ar": "تحويل", "nl": "Converteren", "pl": "Konwertuj", "tr": "Dönüştür",
        "hi": "रूपांतरित करें", "id": "Konversi", "uk": "Конвертувати", "sv": "Konvertera",
    },
    "open_output_folder": {
        "en": "Open Output Folder", "es": "Abrir carpeta de salida",
        "fr": "Ouvrir le dossier de sortie", "de": "Ausgabeordner öffnen",
        "it": "Apri cartella di output", "pt-BR": "Abrir pasta de saída",
        "pt-PT": "Abrir pasta de saída", "ja": "出力フォルダを開く",
        "ko": "출력 폴더 열기", "zh-Hans": "打开输出文件夹", "zh-Hant": "開啟輸出資料夾",
        "ru": "Открыть папку вывода", "ar": "فتح مجلد الإخراج",
        "nl": "Uitvoermap openen", "pl": "Otwórz folder wyjściowy",
        "tr": "Çıktı klasörünü aç", "hi": "आउटपुट फ़ोल्डर खोलें",
        "id": "Buka folder keluaran", "uk": "Відкрити папку виводу", "sv": "Öppna utdatamapp",
    },
    "no_formats_found": {
        "en": "No formats found", "es": "No se encontraron formatos",
        "fr": "Aucun format trouvé", "de": "Keine Formate gefunden",
        "it": "Nessun formato trovato", "pt-BR": "Nenhum formato encontrado",
        "pt-PT": "Nenhum formato encontrado", "ja": "形式が見つかりません",
        "ko": "형식을 찾을 수 없음", "zh-Hans": "未找到格式", "zh-Hant": "找不到格式",
        "ru": "Форматы не найдены", "ar": "لم يُعثر على تنسيقات",
        "nl": "Geen formaten gevonden", "pl": "Nie znaleziono formatów",
        "tr": "Biçim bulunamadı", "hi": "कोई प्रारूप नहीं मिला",
        "id": "Format tidak ditemukan", "uk": "Формати не знайдено", "sv": "Inga format hittades",
    },
    "format_search_hint": {
        "en": "Try a different search or refresh ImageMagick.",
        "es": "Prueba otra búsqueda o actualiza ImageMagick.",
        "fr": "Essayez une autre recherche ou actualisez ImageMagick.",
        "de": "Andere Suche versuchen oder ImageMagick aktualisieren.",
        "it": "Prova un'altra ricerca o aggiorna ImageMagick.",
        "pt-BR": "Tente outra busca ou atualize o ImageMagick.",
        "pt-PT": "Tente outra pesquisa ou atualize o ImageMagick.",
        "ja": "別の検索を試すか、ImageMagick を更新してください。",
        "ko": "다른 검색을 시도하거나 ImageMagick을 새로고침하세요.",
        "zh-Hans": "请尝试其他搜索或刷新 ImageMagick。",
        "zh-Hant": "請嘗試其他搜尋或重新整理 ImageMagick。",
        "ru": "Попробуйте другой запрос или обновите ImageMagick.",
        "ar": "جرّب بحثًا آخر أو حدّث ImageMagick.",
        "nl": "Probeer een andere zoekopdracht of vernieuw ImageMagick.",
        "pl": "Spróbuj innego wyszukiwania lub odśwież ImageMagick.",
        "tr": "Farklı bir arama deneyin veya ImageMagick'i yenileyin.",
        "hi": "दूसरी खोज आज़माएँ या ImageMagick रीफ़्रेश करें।",
        "id": "Coba pencarian lain atau segarkan ImageMagick.",
        "uk": "Спробуйте інший пошук або оновіть ImageMagick.",
        "sv": "Prova en annan sökning eller uppdatera ImageMagick.",
    },
    "visible_formats": {
        "en": "Visible Formats", "es": "Formatos visibles", "fr": "Formats visibles",
        "de": "Sichtbare Formate", "it": "Formati visibili", "pt-BR": "Formatos visíveis",
        "pt-PT": "Formatos visíveis", "ja": "表示する形式", "ko": "표시 형식",
        "zh-Hans": "可见格式", "zh-Hant": "可見格式", "ru": "Видимые форматы",
        "ar": "التنسيقات الظاهرة", "nl": "Zichtbare formaten", "pl": "Widoczne formaty",
        "tr": "Görünen biçimler", "hi": "दृश्य प्रारूप", "id": "Format yang terlihat",
        "uk": "Видимі формати", "sv": "Synliga format",
    },
    "search_formats": {
        "en": "Search formats", "es": "Buscar formatos", "fr": "Rechercher des formats",
        "de": "Formate suchen", "it": "Cerca formati", "pt-BR": "Buscar formatos",
        "pt-PT": "Pesquisar formatos", "ja": "形式を検索", "ko": "형식 검색",
        "zh-Hans": "搜索格式", "zh-Hant": "搜尋格式", "ru": "Поиск форматов",
        "ar": "بحث في التنسيقات", "nl": "Formaten zoeken", "pl": "Szukaj formatów",
        "tr": "Biçim ara", "hi": "प्रारूप खोजें", "id": "Cari format",
        "uk": "Пошук форматів", "sv": "Sök format",
    },
    "done": {
        "en": "Done", "es": "Listo", "fr": "Terminé", "de": "Fertig", "it": "Fine",
        "pt-BR": "Concluído", "pt-PT": "Concluído", "ja": "完了", "ko": "완료",
        "zh-Hans": "完成", "zh-Hant": "完成", "ru": "Готово", "ar": "تم",
        "nl": "Gereed", "pl": "Gotowe", "tr": "Bitti", "hi": "हो गया",
        "id": "Selesai", "uk": "Готово", "sv": "Klar",
    },
    "presets": {
        "en": "Presets", "es": "Preajustes", "fr": "Préréglages", "de": "Voreinstellungen",
        "it": "Preimpostazioni", "pt-BR": "Predefinições", "pt-PT": "Predefinições",
        "ja": "プリセット", "ko": "프리셋", "zh-Hans": "预设", "zh-Hant": "預設",
        "ru": "Пресеты", "ar": "إعدادات مسبقة", "nl": "Voorinstellingen",
        "pl": "Presety", "tr": "Ön ayarlar", "hi": "प्रीसेट", "id": "Prasetel",
        "uk": "Пресети", "sv": "Förinställningar",
    },
    "common_formats": {
        "en": "Common formats", "es": "Formatos comunes", "fr": "Formats courants",
        "de": "Gängige Formate", "it": "Formati comuni", "pt-BR": "Formatos comuns",
        "pt-PT": "Formatos comuns", "ja": "一般的な形式", "ko": "일반 형식",
        "zh-Hans": "常用格式", "zh-Hant": "常用格式", "ru": "Распространённые форматы",
        "ar": "التنسيقات الشائعة", "nl": "Veelgebruikte formaten", "pl": "Popularne formaty",
        "tr": "Yaygın biçimler", "hi": "सामान्य प्रारूप", "id": "Format umum",
        "uk": "Поширені формати", "sv": "Vanliga format",
    },
    "select_all": {
        "en": "Select all", "es": "Seleccionar todo", "fr": "Tout sélectionner",
        "de": "Alle auswählen", "it": "Seleziona tutto", "pt-BR": "Selecionar tudo",
        "pt-PT": "Selecionar tudo", "ja": "すべて選択", "ko": "모두 선택",
        "zh-Hans": "全选", "zh-Hant": "全選", "ru": "Выбрать все",
        "ar": "تحديد الكل", "nl": "Alles selecteren", "pl": "Zaznacz wszystko",
        "tr": "Tümünü seç", "hi": "सभी चुनें", "id": "Pilih semua",
        "uk": "Вибрати все", "sv": "Markera alla",
    },
    "clear_all": {
        "en": "Clear all", "es": "Borrar todo", "fr": "Tout effacer",
        "de": "Alle löschen", "it": "Deseleziona tutto", "pt-BR": "Limpar tudo",
        "pt-PT": "Limpar tudo", "ja": "すべて解除", "ko": "모두 지우기",
        "zh-Hans": "全部清除", "zh-Hant": "全部清除", "ru": "Снять все",
        "ar": "مسح الكل", "nl": "Alles wissen", "pl": "Wyczyść wszystko",
        "tr": "Tümünü temizle", "hi": "सभी साफ़ करें", "id": "Hapus semua",
        "uk": "Очистити все", "sv": "Rensa alla",
    },
    "section_imagemagick": {
        "en": "ImageMagick", "es": "ImageMagick", "fr": "ImageMagick", "de": "ImageMagick",
        "it": "ImageMagick", "pt-BR": "ImageMagick", "pt-PT": "ImageMagick",
        "ja": "ImageMagick", "ko": "ImageMagick", "zh-Hans": "ImageMagick",
        "zh-Hant": "ImageMagick", "ru": "ImageMagick", "ar": "ImageMagick",
        "nl": "ImageMagick", "pl": "ImageMagick", "tr": "ImageMagick",
        "hi": "ImageMagick", "id": "ImageMagick", "uk": "ImageMagick", "sv": "ImageMagick",
    },
    "detected": {
        "en": "Detected", "es": "Detectado", "fr": "Détecté", "de": "Erkannt",
        "it": "Rilevato", "pt-BR": "Detectado", "pt-PT": "Detetado", "ja": "検出済み",
        "ko": "감지됨", "zh-Hans": "已检测", "zh-Hant": "已偵測", "ru": "Обнаружен",
        "ar": "تم الاكتشاف", "nl": "Gedetecteerd", "pl": "Wykryto", "tr": "Algılandı",
        "hi": "पता चला", "id": "Terdeteksi", "uk": "Виявлено", "sv": "Upptäckt",
    },
    "not_detected": {
        "en": "Not detected", "es": "No detectado", "fr": "Non détecté",
        "de": "Nicht erkannt", "it": "Non rilevato", "pt-BR": "Não detectado",
        "pt-PT": "Não detetado", "ja": "未検出", "ko": "감지되지 않음",
        "zh-Hans": "未检测", "zh-Hant": "未偵測", "ru": "Не обнаружен",
        "ar": "لم يُكتشف", "nl": "Niet gedetecteerd", "pl": "Nie wykryto",
        "tr": "Algılanmadı", "hi": "पता नहीं चला", "id": "Tidak terdeteksi",
        "uk": "Не виявлено", "sv": "Ej upptäckt",
    },
    "custom_magick_path": {
        "en": "Custom magick path", "es": "Ruta personalizada de magick",
        "fr": "Chemin magick personnalisé", "de": "Benutzerdefinierter magick-Pfad",
        "it": "Percorso magick personalizzato", "pt-BR": "Caminho personalizado do magick",
        "pt-PT": "Caminho personalizado do magick", "ja": "カスタム magick パス",
        "ko": "사용자 지정 magick 경로", "zh-Hans": "自定义 magick 路径",
        "zh-Hant": "自訂 magick 路徑", "ru": "Пользовательский путь к magick",
        "ar": "مسار magick مخصص", "nl": "Aangepast magick-pad", "pl": "Niestandardowa ścieżka magick",
        "tr": "Özel magick yolu", "hi": "कस्टम magick पथ", "id": "Jalur magick kustom",
        "uk": "Власний шлях до magick", "sv": "Anpassad magick-sökväg",
    },
    "magick_path_placeholder": {
        "en": "/opt/homebrew/bin/magick",
    },
    "apply": {
        "en": "Apply", "es": "Aplicar", "fr": "Appliquer", "de": "Anwenden", "it": "Applica",
        "pt-BR": "Aplicar", "pt-PT": "Aplicar", "ja": "適用", "ko": "적용",
        "zh-Hans": "应用", "zh-Hant": "套用", "ru": "Применить", "ar": "تطبيق",
        "nl": "Toepassen", "pl": "Zastosuj", "tr": "Uygula", "hi": "लागू करें",
        "id": "Terapkan", "uk": "Застосувати", "sv": "Verkställ",
    },
    "refresh": {
        "en": "Refresh", "es": "Actualizar", "fr": "Actualiser", "de": "Aktualisieren",
        "it": "Aggiorna", "pt-BR": "Atualizar", "pt-PT": "Atualizar", "ja": "更新",
        "ko": "새로고침", "zh-Hans": "刷新", "zh-Hant": "重新整理", "ru": "Обновить",
        "ar": "تحديث", "nl": "Vernieuwen", "pl": "Odśwież", "tr": "Yenile",
        "hi": "रीफ़्रेश", "id": "Segarkan", "uk": "Оновити", "sv": "Uppdatera",
    },
    "imagemagick_docs": {
        "en": "ImageMagick documentation", "es": "Documentación de ImageMagick",
        "fr": "Documentation ImageMagick", "de": "ImageMagick-Dokumentation",
        "it": "Documentazione ImageMagick", "pt-BR": "Documentação do ImageMagick",
        "pt-PT": "Documentação do ImageMagick", "ja": "ImageMagick ドキュメント",
        "ko": "ImageMagick 문서", "zh-Hans": "ImageMagick 文档", "zh-Hant": "ImageMagick 文件",
        "ru": "Документация ImageMagick", "ar": "وثائق ImageMagick",
        "nl": "ImageMagick-documentatie", "pl": "Dokumentacja ImageMagick",
        "tr": "ImageMagick belgeleri", "hi": "ImageMagick दस्तावेज़",
        "id": "Dokumentasi ImageMagick", "uk": "Документація ImageMagick",
        "sv": "ImageMagick-dokumentation",
    },
    "imagemagick_required": {
        "en": "ImageMagick required", "es": "ImageMagick requerido",
        "fr": "ImageMagick requis", "de": "ImageMagick erforderlich",
        "it": "ImageMagick richiesto", "pt-BR": "ImageMagick necessário",
        "pt-PT": "ImageMagick necessário", "ja": "ImageMagick が必要です",
        "ko": "ImageMagick 필요", "zh-Hans": "需要 ImageMagick",
        "zh-Hant": "需要 ImageMagick", "ru": "Требуется ImageMagick",
        "ar": "ImageMagick مطلوب", "nl": "ImageMagick vereist", "pl": "Wymagany ImageMagick",
        "tr": "ImageMagick gerekli", "hi": "ImageMagick आवश्यक",
        "id": "ImageMagick diperlukan", "uk": "Потрібен ImageMagick", "sv": "ImageMagick krävs",
    },
    "install_with_homebrew": {
        "en": "Install with Homebrew:", "es": "Instalar con Homebrew:",
        "fr": "Installer avec Homebrew :", "de": "Mit Homebrew installieren:",
        "it": "Installa con Homebrew:", "pt-BR": "Instalar com Homebrew:",
        "pt-PT": "Instalar com Homebrew:", "ja": "Homebrew でインストール:",
        "ko": "Homebrew로 설치:", "zh-Hans": "使用 Homebrew 安装：",
        "zh-Hant": "使用 Homebrew 安裝：", "ru": "Установите через Homebrew:",
        "ar": "ثبّت عبر Homebrew:", "nl": "Installeer met Homebrew:",
        "pl": "Zainstaluj przez Homebrew:", "tr": "Homebrew ile yükle:",
        "hi": "Homebrew से इंस्टॉल करें:", "id": "Instal dengan Homebrew:",
        "uk": "Встановіть через Homebrew:", "sv": "Installera med Homebrew:",
    },
    "custom_path_hint": {
        "en": "Or set a custom path in Converto → Settings.",
        "es": "O establece una ruta personalizada en Converto → Ajustes.",
        "fr": "Ou définissez un chemin dans Converto → Réglages.",
        "de": "Oder Pfad unter Converto → Einstellungen setzen.",
        "it": "Oppure imposta un percorso in Converto → Impostazioni.",
        "pt-BR": "Ou defina um caminho em Converto → Ajustes.",
        "pt-PT": "Ou defina um caminho em Converto → Definições.",
        "ja": "または Converto → 設定でカスタムパスを指定してください。",
        "ko": "또는 Converto → 설정에서 사용자 경로를 지정하세요.",
        "zh-Hans": "或在 Converto → 设置 中指定自定义路径。",
        "zh-Hant": "或在 Converto → 設定 中指定自訂路徑。",
        "ru": "Или укажите путь в Converto → Настройки.",
        "ar": "أو عيّن مسارًا مخصصًا في Converto → الإعدادات.",
        "nl": "Of stel een pad in via Converto → Instellingen.",
        "pl": "Lub ustaw ścieżkę w Converto → Ustawienia.",
        "tr": "Veya Converto → Ayarlar'dan özel yol belirleyin.",
        "hi": "या Converto → सेटिंग्स में कस्टम पथ सेट करें।",
        "id": "Atau atur jalur kustom di Converto → Pengaturan.",
        "uk": "Або вкажіть шлях у Converto → Налаштування.",
        "sv": "Eller ange en sökväg i Converto → Inställningar.",
    },
    "open_settings": {
        "en": "Open Settings", "es": "Abrir ajustes", "fr": "Ouvrir les réglages",
        "de": "Einstellungen öffnen", "it": "Apri impostazioni", "pt-BR": "Abrir ajustes",
        "pt-PT": "Abrir definições", "ja": "設定を開く", "ko": "설정 열기",
        "zh-Hans": "打开设置", "zh-Hant": "開啟設定", "ru": "Открыть настройки",
        "ar": "فتح الإعدادات", "nl": "Instellingen openen", "pl": "Otwórz ustawienia",
        "tr": "Ayarları aç", "hi": "सेटिंग्स खोलें", "id": "Buka pengaturan",
        "uk": "Відкрити налаштування", "sv": "Öppna inställningar",
    },
    "retry": {
        "en": "Retry", "es": "Reintentar", "fr": "Réessayer", "de": "Erneut versuchen",
        "it": "Riprova", "pt-BR": "Tentar novamente", "pt-PT": "Tentar novamente",
        "ja": "再試行", "ko": "다시 시도", "zh-Hans": "重试", "zh-Hant": "重試",
        "ru": "Повторить", "ar": "إعادة المحاولة", "nl": "Opnieuw proberen",
        "pl": "Spróbuj ponownie", "tr": "Yeniden dene", "hi": "पुनः प्रयास",
        "id": "Coba lagi", "uk": "Повторити", "sv": "Försök igen",
    },
    "error_missing_output_folder": {
        "en": "Choose an output folder.", "es": "Elige una carpeta de salida.",
        "fr": "Choisissez un dossier de sortie.", "de": "Wählen Sie einen Ausgabeordner.",
        "it": "Scegli una cartella di output.", "pt-BR": "Escolha uma pasta de saída.",
        "pt-PT": "Escolha uma pasta de saída.", "ja": "出力フォルダを選択してください。",
        "ko": "출력 폴더를 선택하세요.", "zh-Hans": "请选择输出文件夹。",
        "zh-Hant": "請選擇輸出資料夾。", "ru": "Выберите папку для вывода.",
        "ar": "اختر مجلد إخراج.", "nl": "Kies een uitvoermap.", "pl": "Wybierz folder wyjściowy.",
        "tr": "Bir çıktı klasörü seçin.", "hi": "आउटपुट फ़ोल्डर चुनें।",
        "id": "Pilih folder keluaran.", "uk": "Виберіть папку виводу.", "sv": "Välj en utdatamapp.",
    },
    "error_imagemagick_not_found": {
        "en": "ImageMagick was not found. Install it with: brew install imagemagick",
        "es": "No se encontró ImageMagick. Instálalo con: brew install imagemagick",
        "fr": "ImageMagick introuvable. Installez-le avec : brew install imagemagick",
        "de": "ImageMagick nicht gefunden. Installieren mit: brew install imagemagick",
        "it": "ImageMagick non trovato. Installa con: brew install imagemagick",
        "pt-BR": "ImageMagick não encontrado. Instale com: brew install imagemagick",
        "pt-PT": "ImageMagick não encontrado. Instale com: brew install imagemagick",
        "ja": "ImageMagick が見つかりません。brew install imagemagick でインストールしてください",
        "ko": "ImageMagick을 찾을 수 없습니다. brew install imagemagick 으로 설치하세요",
        "zh-Hans": "未找到 ImageMagick。请使用 brew install imagemagick 安装",
        "zh-Hant": "找不到 ImageMagick。請使用 brew install imagemagick 安裝",
        "ru": "ImageMagick не найден. Установите: brew install imagemagick",
        "ar": "لم يُعثر على ImageMagick. ثبّته بـ: brew install imagemagick",
        "nl": "ImageMagick niet gevonden. Installeer met: brew install imagemagick",
        "pl": "Nie znaleziono ImageMagick. Zainstaluj: brew install imagemagick",
        "tr": "ImageMagick bulunamadı. Yükleyin: brew install imagemagick",
        "hi": "ImageMagick नहीं मिला। इंस्टॉल करें: brew install imagemagick",
        "id": "ImageMagick tidak ditemukan. Instal dengan: brew install imagemagick",
        "uk": "ImageMagick не знайдено. Встановіть: brew install imagemagick",
        "sv": "ImageMagick hittades inte. Installera med: brew install imagemagick",
    },
    "error_imagemagick_not_found_mac": {
        "en": "ImageMagick 7 was not found on this Mac.",
        "es": "No se encontró ImageMagick 7 en este Mac.",
        "fr": "ImageMagick 7 est introuvable sur ce Mac.",
        "de": "ImageMagick 7 wurde auf diesem Mac nicht gefunden.",
        "it": "ImageMagick 7 non trovato su questo Mac.",
        "pt-BR": "ImageMagick 7 não foi encontrado neste Mac.",
        "pt-PT": "ImageMagick 7 não foi encontrado neste Mac.",
        "ja": "この Mac に ImageMagick 7 が見つかりません。",
        "ko": "이 Mac에서 ImageMagick 7을 찾을 수 없습니다.",
        "zh-Hans": "在此 Mac 上未找到 ImageMagick 7。",
        "zh-Hant": "在此 Mac 上找不到 ImageMagick 7。",
        "ru": "ImageMagick 7 не найден на этом Mac.",
        "ar": "لم يُعثر على ImageMagick 7 على هذا Mac.",
        "nl": "ImageMagick 7 niet gevonden op deze Mac.",
        "pl": "Nie znaleziono ImageMagick 7 na tym Macu.",
        "tr": "Bu Mac'te ImageMagick 7 bulunamadı.",
        "hi": "इस Mac पर ImageMagick 7 नहीं मिला।",
        "id": "ImageMagick 7 tidak ditemukan di Mac ini.",
        "uk": "ImageMagick 7 не знайдено на цьому Mac.",
        "sv": "ImageMagick 7 hittades inte på denna Mac.",
    },
    "error_list_formats_failed": {
        "en": "Failed to list ImageMagick formats.",
        "es": "No se pudieron listar los formatos de ImageMagick.",
        "fr": "Échec de la liste des formats ImageMagick.",
        "de": "ImageMagick-Formate konnten nicht aufgelistet werden.",
        "it": "Impossibile elencare i formati ImageMagick.",
        "pt-BR": "Falha ao listar formatos do ImageMagick.",
        "pt-PT": "Falha ao listar formatos do ImageMagick.",
        "ja": "ImageMagick の形式一覧を取得できませんでした。",
        "ko": "ImageMagick 형식 목록을 가져오지 못했습니다.",
        "zh-Hans": "无法列出 ImageMagick 格式。",
        "zh-Hant": "無法列出 ImageMagick 格式。",
        "ru": "Не удалось получить список форматов ImageMagick.",
        "ar": "فشل عرض تنسيقات ImageMagick.",
        "nl": "ImageMagick-formaten konden niet worden opgehaald.",
        "pl": "Nie udało się pobrać listy formatów ImageMagick.",
        "tr": "ImageMagick biçimleri listelenemedi.",
        "hi": "ImageMagick प्रारूप सूचीबद्ध नहीं हो सके।",
        "id": "Gagal menampilkan format ImageMagick.",
        "uk": "Не вдалося отримати список форматів ImageMagick.",
        "sv": "Det gick inte att lista ImageMagick-format.",
    },
}

PLURALS = {
    "convert_images": {
        "en": {"one": "Convert %lld image", "other": "Convert %lld images"},
        "es": {"one": "Convertir %lld imagen", "other": "Convertir %lld imágenes"},
        "fr": {"one": "Convertir %lld image", "other": "Convertir %lld images"},
        "de": {"one": "%lld Bild konvertieren", "other": "%lld Bilder konvertieren"},
        "it": {"one": "Converti %lld immagine", "other": "Converti %lld immagini"},
        "pt-BR": {"one": "Converter %lld imagem", "other": "Converter %lld imagens"},
        "pt-PT": {"one": "Converter %lld imagem", "other": "Converter %lld imagens"},
        "ja": {"other": "%lld 件の画像を変換"},
        "ko": {"other": "이미지 %lld개 변환"},
        "zh-Hans": {"other": "转换 %lld 张图片"},
        "zh-Hant": {"other": "轉換 %lld 張圖片"},
        "ru": {"one": "Конвертировать %lld изображение", "few": "Конвертировать %lld изображения", "many": "Конвертировать %lld изображений", "other": "Конвертировать %lld изображения"},
        "ar": {"zero": "تحويل %lld صورة", "one": "تحويل %lld صورة", "two": "تحويل صورتين", "few": "تحويل %lld صور", "many": "تحويل %lld صورة", "other": "تحويل %lld صورة"},
        "nl": {"one": "Converteer %lld afbeelding", "other": "Converteer %lld afbeeldingen"},
        "pl": {"one": "Konwertuj %lld obraz", "few": "Konwertuj %lld obrazy", "many": "Konwertuj %lld obrazów", "other": "Konwertuj %lld obrazu"},
        "tr": {"one": "%lld görseli dönüştür", "other": "%lld görseli dönüştür"},
        "hi": {"one": "%lld छवि रूपांतरित करें", "other": "%lld छवियाँ रूपांतरित करें"},
        "id": {"other": "Konversi %lld gambar"},
        "uk": {"one": "Конвертувати %lld зображення", "few": "Конвертувати %lld зображення", "many": "Конвертувати %lld зображень", "other": "Конвертувати %lld зображення"},
        "sv": {"one": "Konvertera %lld bild", "other": "Konvertera %lld bilder"},
    },
    "converting_progress": {
        "en": {"other": "Converting %1$lld of %2$lld"},
        "es": {"other": "Convirtiendo %1$lld de %2$lld"},
        "fr": {"other": "Conversion %1$lld sur %2$lld"},
        "de": {"other": "Konvertiere %1$lld von %2$lld"},
        "it": {"other": "Conversione %1$lld di %2$lld"},
        "pt-BR": {"other": "Convertendo %1$lld de %2$lld"},
        "pt-PT": {"other": "A converter %1$lld de %2$lld"},
        "ja": {"other": "%1$lld / %2$lld 件を変換中"},
        "ko": {"other": "%1$lld/%2$lld 변환 중"},
        "zh-Hans": {"other": "正在转换 %1$lld / %2$lld"},
        "zh-Hant": {"other": "正在轉換 %1$lld / %2$lld"},
        "ru": {"other": "Конвертация %1$lld из %2$lld"},
        "ar": {"other": "جارٍ تحويل %1$lld من %2$lld"},
        "nl": {"other": "Bezig met %1$lld van %2$lld"},
        "pl": {"other": "Konwertowanie %1$lld z %2$lld"},
        "tr": {"other": "%1$lld / %2$lld dönüştürülüyor"},
        "hi": {"other": "%1$lld में से %2$lld रूपांतरित हो रहा है"},
        "id": {"other": "Mengonversi %1$lld dari %2$lld"},
        "uk": {"other": "Конвертація %1$lld з %2$lld"},
        "sv": {"other": "Konverterar %1$lld av %2$lld"},
    },
}


def unit(value: str, state: str = "translated") -> dict:
    return {"stringUnit": {"state": state, "value": value}}


def build_entry(key: str, translations: dict) -> dict:
    locs = {}
    for lang in LANGUAGES:
        if lang not in translations:
            if "en" in translations:
                locs[lang] = unit(translations["en"])
            continue
        locs[lang] = unit(translations[lang])
    return {"comment": key.replace("_", " "), "localizations": locs}


def build_plural(key: str, forms: dict) -> dict:
    locs = {}
    for lang in LANGUAGES:
        if lang not in forms:
            continue
        plural = {}
        for form, value in forms[lang].items():
            plural[form] = unit(value)
        locs[lang] = {"variations": {"plural": plural}}
    return {"comment": key.replace("_", " "), "localizations": locs}


def main() -> None:
    strings = {}
    for key, translations in STRINGS.items():
        strings[key] = build_entry(key, translations)
        # fill missing langs from en
        en_val = translations.get("en", key)
        for lang in LANGUAGES:
            if lang not in strings[key]["localizations"]:
                strings[key]["localizations"][lang] = unit(en_val)

    for key, forms in PLURALS.items():
        catalog_key = f"{key} %lld" if key == "convert_images" else f"{key} %1$lld %2$lld"
        strings[catalog_key] = build_plural(catalog_key, forms)
        for lang in LANGUAGES:
            if lang not in strings[catalog_key]["localizations"]:
                strings[catalog_key]["localizations"][lang] = strings[catalog_key]["localizations"].get(
                    "en", unit(forms["en"]["other"])
                )

    catalog = {
        "sourceLanguage": "en",
        "strings": strings,
        "version": "1.0",
    }
    out = Path(__file__).resolve().parents[1] / "Converto" / "Localization" / "Localizable.xcstrings"
    out.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {out} ({len(strings)} keys, {len(LANGUAGES)} languages)")


if __name__ == "__main__":
    main()
