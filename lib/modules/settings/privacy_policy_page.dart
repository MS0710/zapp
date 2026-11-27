import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                          '隱私權協議',
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
                    _SectionTitle('ZAPP 隱私權協議'),
                    SizedBox(height: 8),
                    _BodyText(
                      '歡迎使用 ZAPP。為了讓您安心使用本服務，我們向您說明 ZAPP 在您使用夜店、酒吧、活動探索、報名、聊天與相關功能時，如何蒐集、使用、保存與保護您的個人資料。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('一、適用範圍'),
                    _BodyText(
                      '本隱私權協議適用於您在使用 ZAPP 服務期間所提供或產生的資料，包括註冊、登入、個人資料編輯、活動報名、聊天室互動、位置資訊與裝置資訊等。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('二、我們蒐集的資料'),
                    _BodyText(
                      '1. 帳號資料：包含姓名、暱稱、生日、性別、電子郵件、登入資訊與個人頭像。\\n'
                      '2. 使用資料：包含活動報名紀錄、聊天室訊息、點擊紀錄、瀏覽偏好與功能使用狀況。\\n'
                      '3. 裝置與技術資料：包含裝置型號、作業系統版本、推播 token、App 版本與錯誤紀錄。\\n'
                      '4. 位置資料：在您授權下，我們可能蒐集您的定位資訊，用於顯示附近商家、酒吧、夜店與活動內容。\\n'
                      '5. 上傳內容：包含您主動上傳的頭像、活動圖片、聊天圖片與其他內容。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('三、資料使用目的'),
                    _BodyText(
                      '我們蒐集與使用資料的目的包括：\\n'
                      '1. 建立與管理您的帳號。\\n'
                      '2. 提供夜店、酒吧與活動相關內容與地圖探索功能。\\n'
                      '3. 協助您完成報名、互動、聊天與通知接收。\\n'
                      '4. 改善服務穩定性、優化推薦內容與提升使用體驗。\\n'
                      '5. 防範異常行為、濫用、詐欺與違規使用。\\n'
                      '6. 依法律規定或主管機關要求進行必要處理。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('四、聊天室與互動內容'),
                    _BodyText(
                      '您在 ZAPP 聊天室、活動頁面、報名互動中所輸入或上傳的內容，可能會提供給聊天室參與者、活動主辦方或相關商家查看。請您避免在公開或多人互動情境中提供不必要的敏感個資。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('五、位置資訊使用'),
                    _BodyText(
                      '若您同意提供定位權限，ZAPP 會使用您的位置資訊顯示附近活動、商家與地圖內容。您可隨時於裝置系統設定中關閉定位權限，但部分功能可能因此受限。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('六、推播通知'),
                    _BodyText(
                      '為提供活動動態、報名通知、聊天訊息與系統提醒，我們可能使用推播通知。您可隨時在裝置通知設定中調整是否接收推播。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('七、資料分享與揭露'),
                    _BodyText(
                      '除下列情況外，我們不會任意出售、交換或揭露您的個人資料：\\n'
                      '1. 經您明確同意。\\n'
                      '2. 為完成您所要求的服務流程，例如活動報名、商家互動或推播通知。\\n'
                      '3. 配合合法主管機關、司法機關或依法令要求。\\n'
                      '4. 為維護 ZAPP、其他使用者或第三人之權利、財產或安全所必要。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('八、資料保存與安全'),
                    _BodyText(
                      '我們會採取合理的技術與管理措施保護您的資料，避免未經授權的存取、修改、揭露或毀損。您的資料保存期間將依服務目的、法令要求與實際營運需要決定。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('九、您的權利'),
                    _BodyText(
                      '您可依適用法令，就您的個人資料行使查詢、閱覽、更正、更新或刪除等權利。若您欲提出相關申請，可透過 App 內聯絡我們功能與我們聯繫。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('十、未成年使用者'),
                    _BodyText(
                      '若您未達當地法定成年年齡，請在法定代理人或監護人同意與陪同下使用本服務。涉及酒精、夜生活與商家活動內容時，請遵守當地法令與年齡規範。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('十一、協議更新'),
                    _BodyText(
                      '我們可能因服務內容、法規要求或營運需求更新本隱私權協議。更新後內容將公布於 App 內，您於更新後繼續使用 ZAPP，即視為同意更新後之內容。',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('十二、聯絡方式'),
                    _BodyText(
                      '若您對本隱私權協議有任何疑問，請透過 ZAPP 內的聯絡我們功能與我們聯繫。',
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
