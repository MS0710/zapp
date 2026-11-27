import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const Color bg = Color(0xFF2C2C40);
  static const Color divider = Color(0xFF1C1C28);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: const Row(
                      children: [
                        Icon(Icons.chevron_left, color: Colors.white, size: 28),
                        SizedBox(width: 2),
                        Text(
                          '服務協議',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: divider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('ZAPP 服務協議'),
                    SizedBox(height: 8),
                    _BodyText(
                      '歡迎您使用 ZAPP。ZAPP 提供以夜店、酒吧、活動探索、報名、聊天與相關互動為核心的服務。當您註冊、登入或使用本服務時，即表示您已閱讀、理解並同意遵守本服務協議。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('一、服務內容'),
                    _BodyText(
                      'ZAPP 提供之服務包括但不限於：活動資訊瀏覽、商家內容查看、地圖探索、活動報名、聊天室互動、個人資料建立、圖片上傳與系統通知等。實際功能將依產品版本與營運安排調整。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('二、帳號使用規範'),
                    _BodyText(
                      '1. 您應提供真實、完整且可更新的註冊資料。\\n'
                      '2. 您應自行妥善保管帳號與登入資訊，不得出借、轉讓或與他人共用。\\n'
                      '3. 因帳號管理不當造成之損失，應由帳號持有人自行負責。\\n'
                      '4. 若您發現帳號遭未經授權使用，應立即通知我們。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('三、使用者行為規範'),
                    _BodyText(
                      '您同意不會利用 ZAPP 從事以下行為：\\n'
                      '1. 散布不實、誤導、違法、侵權、騷擾、歧視、暴力、猥褻或其他不當內容。\\n'
                      '2. 冒用他人身分、假冒商家或偽造活動資訊。\\n'
                      '3. 以不當方式蒐集他人個資、騷擾他人或進行商業詐騙。\\n'
                      '4. 干擾平台運作、測試漏洞、濫發訊息或以自動化方式大量使用服務。\\n'
                      '5. 上傳侵害他人權利或違反法令之圖片、文字與其他內容。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('四、活動與商家資訊'),
                    _BodyText(
                      'ZAPP 平台內之夜店、酒吧、活動與商家資訊，可能來自商家、活動方或平台整理資料。實際活動內容、入場資格、費用、時間與規則，仍應以主辦方或商家現場公告為準。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('五、聊天室與互動內容'),
                    _BodyText(
                      '您應對自己在聊天室、活動互動與個人頁面中所輸入、上傳或分享之內容負完全責任。若您的內容違反法令、本協議或公共秩序善良風俗，ZAPP 有權移除內容、限制功能或暫停帳號使用。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('六、年齡與法令遵循'),
                    _BodyText(
                      '由於 ZAPP 內容可能涉及夜店、酒吧與酒精相關活動，您應確認自己符合所在地法令所規定之使用年齡與參與資格。若您未符合相關法定條件，請勿使用相關功能或參與相關活動。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('七、停權與終止'),
                    _BodyText(
                      '若您有違反本協議、法令、平台規則或影響其他使用者權益之情形，ZAPP 得視情節採取警告、限制部分功能、刪除內容、暫停帳號或終止服務等措施，且不因此負擔賠償責任。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('八、智慧財產權'),
                    _BodyText(
                      'ZAPP 平台之介面設計、商標、圖像、文字、程式、資料整理與其他內容，除依法屬各權利人所有者外，其權利均受相關法令保護。未經授權，不得重製、改作、散布、公開傳輸或作其他商業使用。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('九、免責聲明'),
                    _BodyText(
                      'ZAPP 盡力維持服務穩定與資訊正確，但對於第三方提供之活動資訊、商家內容、使用者互動內容、活動現場狀況或因網路、系統、裝置等因素造成之延遲、中斷、錯誤或損失，不保證完全無誤，並保留合理範圍內之免責權利。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('十、服務調整'),
                    _BodyText(
                      'ZAPP 得視營運需求，隨時新增、調整、限制或終止部分功能與服務內容。若涉及重大變更，我們將以適當方式於 App 內公告。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('十一、協議修改'),
                    _BodyText(
                      '我們保留修改本服務協議之權利。更新內容公布後，您若繼續使用 ZAPP，即視為同意接受更新後之條款。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('十二、聯絡我們'),
                    _BodyText(
                      '若您對本服務協議有任何疑問，請透過 App 內聯絡我們功能與我們聯繫。',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.7,
        ),
      ),
    );
  }
}
