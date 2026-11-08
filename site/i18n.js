/* Ronda Tahiro — نصوص الصفحات القانونية بأربع لغات
   تُحدَّد اللغة من لغة الجهاز، ويمكن للزائر تغييرها، ويُحفظ اختياره. */
const UPDATED = { ar:'7 نوفمبر 2026', en:'November 7, 2026', es:'7 de noviembre de 2026', zh:'2026年11月7日' };
const MAIL = 'zayntahiri1@gmail.com';

const UI = {
  ar:{ home:'الرئيسية', privacy:'سياسة الخصوصية', terms:'الشروط والأحكام', del:'حذف الحساب',
       contact:'تواصل معنا', back:'← الرئيسية', updated:'آخر تحديث', lang:'اللغة', dir:'rtl' },
  en:{ home:'Home', privacy:'Privacy Policy', terms:'Terms & Conditions', del:'Delete Account',
       contact:'Contact us', back:'← Home', updated:'Last updated', lang:'Language', dir:'ltr' },
  es:{ home:'Inicio', privacy:'Política de privacidad', terms:'Términos y condiciones', del:'Eliminar cuenta',
       contact:'Contáctanos', back:'← Inicio', updated:'Última actualización', lang:'Idioma', dir:'ltr' },
  zh:{ home:'首页', privacy:'隐私政策', terms:'条款与条件', del:'删除账号',
       contact:'联系我们', back:'← 首页', updated:'最后更新', lang:'语言', dir:'ltr' },
};

const LEGAL = {
/* ═══════════════════ الشروط والأحكام ═══════════════════ */
terms:{
ar:{title:'الشروط والأحكام', body:`
<p>مرحباً بك في <strong>Ronda Tahiro</strong>. باستخدامك اللعبة فإنك توافق على هذه الشروط. إن لم توافق عليها، يُرجى عدم استخدام اللعبة.</p>
<h2>1. التعريفات</h2><ul>
<li><strong>«اللعبة»</strong>: تطبيق Ronda Tahiro بكل أوضاعه وخدماته.</li>
<li><strong>«نحن»</strong>: <strong>Ahmed Bakkali Tahiri</strong> — مطوّر اللعبة وناشرها، المملكة المغربية.</li>
<li><strong>«أنت»</strong>: مستخدم اللعبة.</li></ul>
<h2>2. أهلية الاستخدام</h2>
<p>اللعبة موجّهة للجمهور العام. إن كنت دون سنّ الرشد في بلدك، فاستخدامك لها يكون بعلم وليّ أمرك وموافقته.</p>
<h2>3. حسابك</h2><ul>
<li>يمكنك اللعب باسم مستعار دون تسجيل، أو ربط حسابك بـ Google لحفظ تقدّمك ومزامنته بين الأجهزة.</li>
<li>أنت مسؤول عن نشاط حسابك وعن اختيار اسم مستعار لا يتضمّن إساءة أو انتحالاً لشخصية غيرك.</li>
<li>يحقّ لنا تغيير أو إزالة أي اسم مستعار مخالف.</li></ul>
<h2>4. العملات الافتراضية</h2>
<div class="note"><strong>لا توجد مشتريات داخل اللعبة حالياً.</strong> الذهب والجواهر تُكتسب مجاناً عبر المباريات والمكافآت اليومية والصناديق.</div><ul>
<li>العملات الافتراضية <strong>ليست نقوداً ولا تحمل أي قيمة مالية حقيقية</strong>، ولا يمكن استبدالها بمال أو تحويلها خارج اللعبة.</li>
<li>لا تملك هذه العملات ملكيةً قانونية، وإنما تُمنح لك رخصة محدودة لاستعمالها داخل اللعبة.</li>
<li>قد نعدّل أرصدتها أو قواعد كسبها في أي وقت لأسباب تتعلّق بالتوازن أو مكافحة الغشّ.</li>
<li>تنتهي رخصتها بانتهاء حسابك أو بإيقاف الخدمة، دون تعويض.</li>
<li>إن أُضيفت مشتريات مستقبلاً، فستخضع لشروط Google Play وسياسات الاسترداد الخاصة به.</li></ul>
<h2>5. السلوك المقبول</h2><p>يُمنع أثناء استخدام اللعبة:</p><ul>
<li>الغشّ أو استعمال برامج مساعدة أو تعديل اللعبة أو استغلال الثغرات.</li>
<li>التلاعب بالترتيب أو إنشاء حسابات وهمية لرفع النقاط.</li>
<li>مضايقة اللاعبين الآخرين أو إرسال محتوى مسيء أو غير قانوني.</li>
<li>محاولة تعطيل الخوادم أو الوصول غير المصرَّح به إليها.</li></ul>
<p>مخالفة ذلك قد تؤدّي إلى تصفير النقاط أو تعليق الحساب أو حظره نهائياً.</p>
<h2>6. اللعب الجماعي</h2>
<p>يعتمد اللعب عبر الإنترنت على اتصالك وعلى خدمات طرف ثالث. لا نضمن استمراريته دون انقطاع، ولا نتحمّل مسؤولية مباراة انقطعت أو نتيجة ضاعت بسبب الشبكة أو عطل تقني.</p>
<h2>7. الإعلانات</h2>
<p>تعرض اللعبة إعلانات عبر Google AdMob لتمويل تطويرها. الإعلانات من طرف ثالث ولا نتحكّم في محتواها.</p>
<h2>8. خدمات الطرف الثالث</h2>
<p>تستعين اللعبة بخدمات من Google Play وAdMob وFirebase وSupabase ومزوّدات اتصال اللعب الجماعي. يخضع استخدامها لشروط تلك الجهات.</p>
<h2>9. الملكية الفكرية</h2>
<p>اللعبة ورسومها وتصميمها وشيفرتها واسمها مملوكة لنا ومحمية بالقانون، ولا يُسمح بنسخها أو تعديلها أو إعادة توزيعها دون إذن كتابي.</p>
<p>أما لعبة روندة نفسها، كتراث شعبي مغربي، فهي ملك للجميع.</p>
<h2>10. التعديلات على اللعبة</h2>
<p>قد نُحدّث اللعبة أو نضيف ميزات أو نزيلها أو نغيّر قواعد النقاط في أي وقت، وقد نوقف الخدمة بإشعار معقول متى أمكن.</p>
<h2>11. إنهاء الاستخدام</h2>
<p>يمكنك حذف حسابك متى شئت عبر <a href="/delete">صفحة حذف الحساب</a>. ويحقّ لنا تعليق وصولك عند مخالفة هذه الشروط.</p>
<h2>12. إخلاء المسؤولية</h2>
<p>تُقدَّم اللعبة «كما هي» دون أي ضمان صريح أو ضمني، وأنت تستخدمها على مسؤوليتك.</p>
<h2>13. حدود المسؤولية</h2>
<p>في حدود ما يسمح به القانون، لا نتحمّل مسؤولية أضرار غير مباشرة أو تبعية، ولا فقدان بيانات أو عملات افتراضية أو تقدّم في اللعبة.</p>
<h2>14. تعديل هذه الشروط</h2>
<p>قد نُحدّث هذه الشروط، ويُنشر التحديث هنا مع تغيير تاريخ «آخر تحديث». واستمرارك في الاستخدام بعده يعدّ قبولاً بها.</p>
<h2>15. القانون المطبَّق</h2>
<p>تخضع هذه الشروط لقوانين المملكة المغربية، وتختصّ المحاكم المغربية المختصّة بالنظر في أي نزاع ينشأ عنها.</p>
<h2>16. التواصل</h2><p>المطوّر: <strong>Ahmed Bakkali Tahiri</strong> — المملكة المغربية.<br>لأي سؤال: <a href="mailto:${MAIL}">${MAIL}</a></p>`},

en:{title:'Terms & Conditions', body:`
<p>Welcome to <strong>Ronda Tahiro</strong>. By using the game you agree to these Terms. If you do not agree, please do not use the game.</p>
<h2>1. Definitions</h2><ul>
<li><strong>"The Game"</strong>: the Ronda application, all its modes and services.</li>
<li><strong>"We"</strong>: <strong>Ahmed Bakkali Tahiri</strong> — developer and publisher of the game, Kingdom of Morocco.</li>
<li><strong>"You"</strong>: the user of the game.</li></ul>
<h2>2. Eligibility</h2>
<p>The game is intended for a general audience. If you are under the age of majority in your country, you may use it only with the knowledge and consent of your parent or guardian.</p>
<h2>3. Your account</h2><ul>
<li>You may play with a nickname without registering, or link a Google account to save and sync your progress across devices.</li>
<li>You are responsible for activity on your account and for choosing a nickname that is not abusive or impersonating someone else.</li>
<li>We may change or remove any nickname that violates these Terms.</li></ul>
<h2>4. Virtual currency</h2>
<div class="note"><strong>There are currently no in-app purchases.</strong> Coins and gems are earned for free through matches, daily rewards and chests.</div><ul>
<li>Virtual currency is <strong>not money and has no real-world monetary value</strong>. It cannot be exchanged for cash or transferred outside the game.</li>
<li>You do not own it; you receive a limited licence to use it inside the game.</li>
<li>We may adjust balances or earning rules at any time for game balance or anti-cheat reasons.</li>
<li>The licence ends when your account ends or the service is discontinued, without compensation.</li>
<li>If purchases are added in future, they will be governed by Google Play's terms and refund policies.</li></ul>
<h2>5. Acceptable use</h2><p>While using the game you must not:</p><ul>
<li>Cheat, use helper software, modify the game, or exploit bugs.</li>
<li>Manipulate the leaderboard or create fake accounts to inflate scores.</li>
<li>Harass other players or send abusive or unlawful content.</li>
<li>Attempt to disrupt our servers or gain unauthorised access to them.</li></ul>
<p>Violations may result in score resets, account suspension, or a permanent ban.</p>
<h2>6. Online multiplayer</h2>
<p>Online play depends on your connection and on third-party services. We do not guarantee uninterrupted availability and are not responsible for a match that drops or a result lost to network or technical failure.</p>
<h2>7. Advertising</h2>
<p>The game shows ads through Google AdMob to fund its development. Ads come from third parties and we do not control their content.</p>
<h2>8. Third-party services</h2>
<p>The game relies on Google Play, AdMob, Firebase, Supabase and multiplayer connectivity providers. Your use of those is subject to their own terms.</p>
<h2>9. Intellectual property</h2>
<p>The game, its artwork, design, code and name are owned by us and protected by law. Copying, modifying or redistributing them without written permission is not allowed.</p>
<p>The game of Ronda itself, as Moroccan folk heritage, belongs to everyone.</p>
<h2>10. Changes to the game</h2>
<p>We may update the game, add or remove features, or change scoring rules at any time, and may discontinue the service with reasonable notice where possible.</p>
<h2>11. Termination</h2>
<p>You may delete your account at any time via the <a href="/delete">account deletion page</a>. We may suspend your access if you breach these Terms.</p>
<h2>12. Disclaimer</h2>
<p>The game is provided "as is" without warranty of any kind, express or implied. You use it at your own risk.</p>
<h2>13. Limitation of liability</h2>
<p>To the extent permitted by law, we are not liable for indirect or consequential damages, nor for loss of data, virtual currency or game progress.</p>
<h2>14. Changes to these Terms</h2>
<p>We may update these Terms. Updates are published here with a new "Last updated" date, and continued use after that constitutes acceptance.</p>
<h2>15. Governing law</h2>
<p>These Terms are governed by the laws of the Kingdom of Morocco, and the competent Moroccan courts have jurisdiction over any dispute arising from them.</p>
<h2>16. Contact</h2><p>Developer: <strong>Ahmed Bakkali Tahiri</strong> — Kingdom of Morocco.<br>Any questions: <a href="mailto:${MAIL}">${MAIL}</a></p>`},

es:{title:'Términos y condiciones', body:`
<p>Bienvenido a <strong>Ronda Tahiro</strong>. Al usar el juego aceptas estos Términos. Si no estás de acuerdo, no uses el juego.</p>
<h2>1. Definiciones</h2><ul>
<li><strong>«El Juego»</strong>: la aplicación Ronda, con todos sus modos y servicios.</li>
<li><strong>«Nosotros»</strong>: <strong>Ahmed Bakkali Tahiri</strong> — desarrollador y editor del juego, Reino de Marruecos.</li>
<li><strong>«Tú»</strong>: el usuario del juego.</li></ul>
<h2>2. Elegibilidad</h2>
<p>El juego está dirigido al público general. Si eres menor de edad en tu país, solo puedes usarlo con el conocimiento y consentimiento de tu padre, madre o tutor.</p>
<h2>3. Tu cuenta</h2><ul>
<li>Puedes jugar con un apodo sin registrarte, o vincular una cuenta de Google para guardar y sincronizar tu progreso entre dispositivos.</li>
<li>Eres responsable de la actividad de tu cuenta y de elegir un apodo que no sea ofensivo ni suplante a otra persona.</li>
<li>Podemos cambiar o eliminar cualquier apodo que infrinja estos Términos.</li></ul>
<h2>4. Moneda virtual</h2>
<div class="note"><strong>Actualmente no hay compras dentro de la aplicación.</strong> Las monedas y gemas se obtienen gratis mediante partidas, recompensas diarias y cofres.</div><ul>
<li>La moneda virtual <strong>no es dinero y no tiene valor monetario real</strong>. No puede canjearse por dinero ni transferirse fuera del juego.</li>
<li>No eres su propietario: recibes una licencia limitada para usarla dentro del juego.</li>
<li>Podemos ajustar saldos o reglas de obtención en cualquier momento por equilibrio del juego o para combatir trampas.</li>
<li>La licencia termina al cerrarse tu cuenta o el servicio, sin compensación.</li>
<li>Si se añaden compras en el futuro, se regirán por los términos y políticas de reembolso de Google Play.</li></ul>
<h2>5. Uso aceptable</h2><p>Al usar el juego no debes:</p><ul>
<li>Hacer trampas, usar programas auxiliares, modificar el juego o explotar fallos.</li>
<li>Manipular la clasificación o crear cuentas falsas para inflar puntuaciones.</li>
<li>Acosar a otros jugadores ni enviar contenido ofensivo o ilegal.</li>
<li>Intentar interrumpir nuestros servidores o acceder a ellos sin autorización.</li></ul>
<p>Las infracciones pueden conllevar el reinicio de puntos, la suspensión o el bloqueo permanente de la cuenta.</p>
<h2>6. Juego en línea</h2>
<p>El juego en línea depende de tu conexión y de servicios de terceros. No garantizamos disponibilidad ininterrumpida ni somos responsables de una partida cortada o un resultado perdido por fallos de red o técnicos.</p>
<h2>7. Publicidad</h2>
<p>El juego muestra anuncios mediante Google AdMob para financiar su desarrollo. Los anuncios provienen de terceros y no controlamos su contenido.</p>
<h2>8. Servicios de terceros</h2>
<p>El juego utiliza Google Play, AdMob, Firebase, Supabase y proveedores de conectividad multijugador. Su uso está sujeto a los términos de esas entidades.</p>
<h2>9. Propiedad intelectual</h2>
<p>El juego, sus gráficos, diseño, código y nombre nos pertenecen y están protegidos por la ley. No se permite copiarlos, modificarlos ni redistribuirlos sin permiso escrito.</p>
<p>El juego de Ronda en sí, como patrimonio popular marroquí, pertenece a todos.</p>
<h2>10. Cambios en el juego</h2>
<p>Podemos actualizar el juego, añadir o quitar funciones o cambiar las reglas de puntuación en cualquier momento, y podemos descontinuar el servicio con aviso razonable cuando sea posible.</p>
<h2>11. Finalización</h2>
<p>Puedes eliminar tu cuenta cuando quieras desde la <a href="/delete">página de eliminación</a>. Podemos suspender tu acceso si incumples estos Términos.</p>
<h2>12. Exención de responsabilidad</h2>
<p>El juego se ofrece «tal cual», sin garantía de ningún tipo, expresa o implícita. Lo usas bajo tu propia responsabilidad.</p>
<h2>13. Limitación de responsabilidad</h2>
<p>En la medida permitida por la ley, no somos responsables de daños indirectos o derivados, ni de la pérdida de datos, moneda virtual o progreso.</p>
<h2>14. Cambios en estos Términos</h2>
<p>Podemos actualizar estos Términos. Las actualizaciones se publican aquí con una nueva fecha de «Última actualización», y el uso continuado implica su aceptación.</p>
<h2>15. Ley aplicable</h2>
<p>Estos Términos se rigen por las leyes del Reino de Marruecos, y los tribunales marroquíes competentes conocerán de cualquier disputa derivada de ellos.</p>
<h2>16. Contacto</h2><p>Desarrollador: <strong>Ahmed Bakkali Tahiri</strong> — Reino de Marruecos.<br>Cualquier consulta: <a href="mailto:${MAIL}">${MAIL}</a></p>`},

zh:{title:'条款与条件', body:`
<p>欢迎使用 <strong>Ronda Tahiro</strong>。使用本游戏即表示您同意本条款。若不同意，请勿使用本游戏。</p>
<h2>1. 定义</h2><ul>
<li><strong>“本游戏”</strong>：Ronda 应用及其全部模式与服务。</li>
<li><strong>“我们”</strong>：<strong>Ahmed Bakkali Tahiri</strong> —— 本游戏的开发者与发行者，摩洛哥王国。</li>
<li><strong>“您”</strong>：本游戏的用户。</li></ul>
<h2>2. 使用资格</h2>
<p>本游戏面向一般公众。若您未达所在国家的成年年龄，须在父母或监护人知情并同意的情况下使用。</p>
<h2>3. 您的账号</h2><ul>
<li>您可以使用昵称直接游玩而无需注册，也可以关联 Google 账号以保存进度并在多设备间同步。</li>
<li>您需对账号活动负责，且昵称不得含有侮辱内容或冒充他人。</li>
<li>我们有权更改或删除任何违规昵称。</li></ul>
<h2>4. 虚拟货币</h2>
<div class="note"><strong>目前没有任何应用内购买。</strong>金币与宝石均通过对局、每日奖励和宝箱免费获得。</div><ul>
<li>虚拟货币<strong>不是货币，也不具有任何现实金钱价值</strong>，不可兑换现金或转移至游戏之外。</li>
<li>您不拥有其所有权，仅获得在游戏内使用的有限许可。</li>
<li>出于平衡性或反作弊考虑，我们可随时调整余额或获取规则。</li>
<li>账号终止或服务停止时该许可即告结束，且不予补偿。</li>
<li>若日后加入购买功能，将适用 Google Play 的条款与退款政策。</li></ul>
<h2>5. 可接受的行为</h2><p>使用本游戏时，不得：</p><ul>
<li>作弊、使用辅助程序、修改游戏或利用漏洞。</li>
<li>操纵排行榜或创建虚假账号刷分。</li>
<li>骚扰其他玩家或发送侮辱性、违法内容。</li>
<li>试图干扰我们的服务器或未经授权访问。</li></ul>
<p>违反上述规定可能导致分数清零、账号暂停或永久封禁。</p>
<h2>6. 在线多人游戏</h2>
<p>在线对战依赖您的网络连接及第三方服务。我们不保证服务不中断，也不对因网络或技术故障导致的掉线或成绩丢失负责。</p>
<h2>7. 广告</h2>
<p>本游戏通过 Google AdMob 展示广告以支持开发。广告来自第三方，其内容不受我们控制。</p>
<h2>8. 第三方服务</h2>
<p>本游戏使用 Google Play、AdMob、Firebase、Supabase 及多人联机服务商。使用这些服务须遵守其各自条款。</p>
<h2>9. 知识产权</h2>
<p>本游戏及其美术、设计、代码与名称归我们所有并受法律保护，未经书面许可不得复制、修改或再分发。</p>
<p>而 Ronda 这一纸牌玩法本身属于摩洛哥民间文化遗产，为所有人共有。</p>
<h2>10. 游戏变更</h2>
<p>我们可能随时更新游戏、增删功能或调整计分规则，并在可能的情况下提前合理通知后停止服务。</p>
<h2>11. 终止</h2>
<p>您可随时通过<a href="/delete">删除账号页面</a>删除账号。若您违反本条款，我们可暂停您的访问。</p>
<h2>12. 免责声明</h2>
<p>本游戏按“现状”提供，不作任何明示或暗示的保证。您须自行承担使用风险。</p>
<h2>13. 责任限制</h2>
<p>在法律允许范围内，我们不对间接或附带损失负责，也不对数据、虚拟货币或游戏进度的丢失负责。</p>
<h2>14. 条款变更</h2>
<p>我们可能更新本条款，更新后将在此页公布并更改“最后更新”日期。继续使用即视为接受。</p>
<h2>15. 适用法律</h2>
<p>本条款受摩洛哥王国法律管辖，由摩洛哥主管法院管辖由此产生的任何争议。</p>
<h2>16. 联系方式</h2><p>开发者：<strong>Ahmed Bakkali Tahiri</strong> —— 摩洛哥王国。<br>如有疑问：<a href="mailto:${MAIL}">${MAIL}</a></p>`}
},

/* ═══════════════════ سياسة الخصوصية ═══════════════════ */
privacy:{
ar:{title:'سياسة الخصوصية', body:`
<p>المسؤول عن معالجة البيانات: <strong>Ahmed Bakkali Tahiri</strong> — المملكة المغربية — <a href="mailto:${MAIL}">${MAIL}</a></p>
<div class="note">باختصار: لا نطلب موقعك ولا جهات اتصالك ولا ملفاتك ولا الكاميرا ولا الميكروفون. اللعبة تطلب أربع صلاحيات فقط، كلّها لتشغيل اللعب والإعلانات.</div>
<h2>1. ما الذي نجمعه</h2>
<p><strong>بيانات تُدخلها أنت:</strong></p><ul>
<li>الاسم المستعار الذي تختاره.</li>
<li>صورة رمزية أو صورة ترفعها اختيارياً (تُحفظ على جهازك).</li></ul>
<p><strong>إن ربطتَ حسابك بـ Google (اختياري):</strong></p><ul>
<li>اسمك وبريدك الإلكتروني وصورة حسابك.</li>
<li>معرّف حساب لا يكشف هويتك، لربط تقدّمك بين أجهزتك.</li></ul>
<p><strong>بيانات اللعب:</strong> عدد المباريات والانتصارات والنقاط والمستوى والإنجازات، والعملات الافتراضية.</p>
<p><strong>بيانات تقنية:</strong> معرّف الإعلانات، وإحصاءات استخدام مجمّعة عبر Firebase Analytics، وتقارير أعطال.</p>
<h2>2. ما لا نجمعه</h2>
<p>لا نجمع موقعك الجغرافي، ولا جهات اتصالك، ولا رسائلك، ولا سجلّ مكالماتك، ولا ملفاتك، ولا نستعمل الكاميرا أو الميكروفون. ولا نطلب أي بيانات بنكية — فاللعبة لا تحوي مشتريات.</p>
<h2>3. الصلاحيات التي تطلبها اللعبة</h2><ul>
<li><strong>الإنترنت</strong> وحالة الشبكة — للّعب الجماعي والترتيب والإعلانات.</li>
<li><strong>الاهتزاز</strong> — للإحساس اللمسي عند اللعب.</li>
<li><strong>معرّف الإعلانات</strong> — لعرض إعلانات AdMob.</li></ul>
<h2>4. لماذا نستعملها</h2><ul>
<li>تشغيل المباريات الجماعية وربطك بلاعبين آخرين.</li>
<li>حفظ تقدّمك واستعادته عند تغيير الهاتف.</li>
<li>عرض لوحة الترتيب — ويظهر فيها اسمك المستعار وصورتك ونقاطك للاعبين الآخرين.</li>
<li>عرض الإعلانات التي تموّل تطوير اللعبة، وإصلاح الأعطال.</li></ul>
<h2>5. أين تُحفظ بياناتك</h2><ul>
<li><strong>على جهازك:</strong> إعداداتك وتقدّمك وصورتك المرفوعة.</li>
<li><strong>على خوادمنا (Supabase):</strong> تقدّمك وترتيبك، إن ربطتَ حسابك بـ Google.</li>
<li><strong>لدى شركاء التشغيل:</strong> Google (Play وAdMob وFirebase) ومزوّدات اللعب الجماعي.</li></ul>
<p>وقد تُعالَج على خوادم خارج بلدك، وفق سياسات تلك الجهات.</p>
<h2>6. ما نشاركه</h2>
<p><strong>لا نبيع بياناتك، ولا نشاركها مع معلنين لأغراض تسويقية.</strong> نشاركها فقط مع مزوّدي الخدمات أعلاه بالقدر اللازم للتشغيل، أو إذا فرض القانون ذلك.</p>
<h2>7. الأطفال</h2>
<p>اللعبة غير موجّهة لمن هم دون 13 عاماً، ولا نجمع بياناتهم عن علم. إن كنت وليّ أمر وتعتقد أن طفلك زوّدنا ببيانات، راسلنا لنحذفها.</p>
<h2>8. حقوقك</h2><ul>
<li><strong>الاطّلاع</strong> على بياناتك المحفوظة لدينا.</li>
<li><strong>التصحيح</strong> — غيّر اسمك وصورتك من داخل اللعبة.</li>
<li><strong>الحذف</strong> — عبر <a href="/delete">صفحة حذف الحساب</a>.</li>
<li><strong>إلغاء الربط</strong> — زرّ «إلغاء الربط بـ Google» داخل اللعبة.</li>
<li><strong>تصفير معرّف الإعلانات</strong> — من إعدادات هاتفك: الإعدادات ← Google ← الإعلانات.</li></ul>
<h2>9. الاحتفاظ بالبيانات</h2>
<p>نحتفظ ببياناتك ما دام حسابك قائماً. وعند طلب الحذف تُمحى خلال 30 يوماً، عدا ما يلزم قانونياً.</p>
<h2>10. الأمان</h2>
<p>تنتقل البيانات مشفّرة عبر HTTPS، ويحمي الخادم صفوف كل لاعب بحيث لا يصل أحد إلى بيانات غيره. ومع ذلك لا توجد وسيلة آمنة بشكل مطلق.</p>
<h2>11. تحديث هذه السياسة</h2><p>قد نُحدّثها، ويُنشر التحديث هنا مع تغيير تاريخ «آخر تحديث».</p>
<h2>12. التواصل</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`},

en:{title:'Privacy Policy', body:`
<p>Data controller: <strong>Ahmed Bakkali Tahiri</strong> — Kingdom of Morocco — <a href="mailto:${MAIL}">${MAIL}</a></p>
<div class="note">In short: we do not ask for your location, contacts, files, camera or microphone. The game requests only four permissions, all needed to run gameplay and ads.</div>
<h2>1. What we collect</h2>
<p><strong>Data you provide:</strong></p><ul>
<li>The nickname you choose.</li>
<li>An avatar or a photo you optionally upload (stored on your device).</li></ul>
<p><strong>If you link a Google account (optional):</strong></p><ul>
<li>Your name, email address and account photo.</li>
<li>A non-identifying account ID used to link your progress across your devices.</li></ul>
<p><strong>Gameplay data:</strong> matches, wins, points, level, achievements and in-game virtual currency.</p>
<p><strong>Technical data:</strong> advertising ID, aggregated usage statistics via Firebase Analytics, and crash reports.</p>
<h2>2. What we do not collect</h2>
<p>We do not collect your location, contacts, messages, call log or files, and we do not use the camera or microphone. We never ask for banking details — the game has no purchases.</p>
<h2>3. Permissions the game requests</h2><ul>
<li><strong>Internet</strong> and network state — for multiplayer, leaderboards and ads.</li>
<li><strong>Vibration</strong> — for haptic feedback during play.</li>
<li><strong>Advertising ID</strong> — to show AdMob ads.</li></ul>
<h2>4. Why we use it</h2><ul>
<li>To run multiplayer matches and connect you with other players.</li>
<li>To save your progress and restore it when you change phones.</li>
<li>To show the leaderboard — your nickname, photo and points are visible to other players there.</li>
<li>To display the ads that fund development, and to fix crashes.</li></ul>
<h2>5. Where your data is stored</h2><ul>
<li><strong>On your device:</strong> your settings, progress and uploaded photo.</li>
<li><strong>On our servers (Supabase):</strong> your progress and ranking, if you linked a Google account.</li>
<li><strong>With operating partners:</strong> Google (Play, AdMob, Firebase) and multiplayer connectivity providers.</li></ul>
<p>Data may be processed on servers outside your country, under those providers' policies.</p>
<h2>6. What we share</h2>
<p><strong>We do not sell your data and do not share it with advertisers for marketing.</strong> We share it only with the service providers above, as far as needed to operate the game, or where the law requires it.</p>
<h2>7. Children</h2>
<p>The game is not directed at children under 13 and we do not knowingly collect their data. If you are a parent and believe your child provided us data, contact us and we will delete it.</p>
<h2>8. Your rights</h2><ul>
<li><strong>Access</strong> the data we hold about you.</li>
<li><strong>Correction</strong> — change your name and photo inside the game.</li>
<li><strong>Deletion</strong> — via the <a href="/delete">account deletion page</a>.</li>
<li><strong>Unlinking</strong> — the "Unlink Google" button inside the game.</li>
<li><strong>Reset your advertising ID</strong> — phone Settings → Google → Ads.</li></ul>
<h2>9. Data retention</h2>
<p>We keep your data while your account exists. On a deletion request it is erased within 30 days, except what the law requires us to keep.</p>
<h2>10. Security</h2>
<p>Data travels encrypted over HTTPS, and the server isolates each player's rows so no one can reach another player's data. No method of transmission or storage is completely secure, however.</p>
<h2>11. Changes to this policy</h2><p>We may update it; updates appear here with a new "Last updated" date.</p>
<h2>12. Contact</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`},

es:{title:'Política de privacidad', body:`
<p>Responsable del tratamiento: <strong>Ahmed Bakkali Tahiri</strong> — Reino de Marruecos — <a href="mailto:${MAIL}">${MAIL}</a></p>
<div class="note">En resumen: no pedimos tu ubicación, contactos, archivos, cámara ni micrófono. El juego solicita solo cuatro permisos, todos necesarios para jugar y mostrar anuncios.</div>
<h2>1. Qué recopilamos</h2>
<p><strong>Datos que tú proporcionas:</strong></p><ul>
<li>El apodo que elijas.</li>
<li>Un avatar o una foto que subas de forma opcional (se guarda en tu dispositivo).</li></ul>
<p><strong>Si vinculas una cuenta de Google (opcional):</strong></p><ul>
<li>Tu nombre, correo electrónico y foto de la cuenta.</li>
<li>Un identificador que no revela tu identidad, para vincular tu progreso entre dispositivos.</li></ul>
<p><strong>Datos de juego:</strong> partidas, victorias, puntos, nivel, logros y moneda virtual.</p>
<p><strong>Datos técnicos:</strong> identificador de publicidad, estadísticas agregadas mediante Firebase Analytics e informes de fallos.</p>
<h2>2. Qué no recopilamos</h2>
<p>No recopilamos tu ubicación, contactos, mensajes, registro de llamadas ni archivos, y no usamos la cámara ni el micrófono. Nunca pedimos datos bancarios: el juego no tiene compras.</p>
<h2>3. Permisos que solicita el juego</h2><ul>
<li><strong>Internet</strong> y estado de la red — para el modo multijugador, la clasificación y los anuncios.</li>
<li><strong>Vibración</strong> — para la respuesta táctil durante el juego.</li>
<li><strong>Identificador de publicidad</strong> — para mostrar anuncios de AdMob.</li></ul>
<h2>4. Para qué los usamos</h2><ul>
<li>Para ejecutar partidas multijugador y conectarte con otros jugadores.</li>
<li>Para guardar tu progreso y restaurarlo al cambiar de teléfono.</li>
<li>Para mostrar la clasificación: tu apodo, foto y puntos son visibles para otros jugadores allí.</li>
<li>Para mostrar los anuncios que financian el desarrollo y corregir fallos.</li></ul>
<h2>5. Dónde se guardan tus datos</h2><ul>
<li><strong>En tu dispositivo:</strong> ajustes, progreso y foto subida.</li>
<li><strong>En nuestros servidores (Supabase):</strong> progreso y clasificación, si vinculaste una cuenta de Google.</li>
<li><strong>Con socios operativos:</strong> Google (Play, AdMob, Firebase) y proveedores de conectividad multijugador.</li></ul>
<p>Los datos pueden procesarse en servidores fuera de tu país, según las políticas de esos proveedores.</p>
<h2>6. Qué compartimos</h2>
<p><strong>No vendemos tus datos ni los compartimos con anunciantes con fines de marketing.</strong> Solo los compartimos con los proveedores mencionados, en la medida necesaria para operar el juego, o cuando la ley lo exija.</p>
<h2>7. Menores</h2>
<p>El juego no está dirigido a menores de 13 años y no recopilamos sus datos a sabiendas. Si eres padre, madre o tutor y crees que tu hijo nos facilitó datos, escríbenos y los eliminaremos.</p>
<h2>8. Tus derechos</h2><ul>
<li><strong>Acceso</strong> a los datos que tenemos sobre ti.</li>
<li><strong>Rectificación</strong> — cambia tu nombre y foto dentro del juego.</li>
<li><strong>Supresión</strong> — mediante la <a href="/delete">página de eliminación de cuenta</a>.</li>
<li><strong>Desvinculación</strong> — el botón «Desvincular Google» dentro del juego.</li>
<li><strong>Restablecer el identificador de publicidad</strong> — Ajustes del teléfono → Google → Anuncios.</li></ul>
<h2>9. Conservación</h2>
<p>Conservamos tus datos mientras exista tu cuenta. Tras una solicitud de eliminación se borran en un plazo de 30 días, salvo lo que la ley obligue a conservar.</p>
<h2>10. Seguridad</h2>
<p>Los datos viajan cifrados por HTTPS y el servidor aísla las filas de cada jugador, de modo que nadie accede a los datos de otro. Aun así, ningún método es completamente seguro.</p>
<h2>11. Cambios en esta política</h2><p>Podemos actualizarla; las novedades aparecen aquí con una nueva fecha de «Última actualización».</p>
<h2>12. Contacto</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`},

zh:{title:'隐私政策', body:`
<p>数据控制者：<strong>Ahmed Bakkali Tahiri</strong> —— 摩洛哥王国 —— <a href="mailto:${MAIL}">${MAIL}</a></p>
<div class="note">简而言之：我们不索取您的位置、通讯录、文件、相机或麦克风。本游戏仅申请四项权限，均用于运行对局与展示广告。</div>
<h2>1. 我们收集什么</h2>
<p><strong>您提供的数据：</strong></p><ul>
<li>您选择的昵称。</li>
<li>您可选上传的头像或照片（保存在您的设备上）。</li></ul>
<p><strong>若您关联 Google 账号（可选）：</strong></p><ul>
<li>您的姓名、电子邮箱与账号头像。</li>
<li>一个不暴露身份的账号标识，用于在多设备间关联您的进度。</li></ul>
<p><strong>游戏数据：</strong>对局数、胜场、积分、等级、成就与游戏内虚拟货币。</p>
<p><strong>技术数据：</strong>广告标识符、经 Firebase Analytics 汇总的使用统计，以及崩溃报告。</p>
<h2>2. 我们不收集什么</h2>
<p>我们不收集您的位置、通讯录、短信、通话记录或文件，也不使用相机或麦克风。我们从不索取银行信息——本游戏没有任何购买功能。</p>
<h2>3. 本游戏申请的权限</h2><ul>
<li><strong>网络</strong>与网络状态——用于多人对战、排行榜与广告。</li>
<li><strong>振动</strong>——用于游戏中的触感反馈。</li>
<li><strong>广告标识符</strong>——用于展示 AdMob 广告。</li></ul>
<h2>4. 使用目的</h2><ul>
<li>运行多人对局并为您匹配其他玩家。</li>
<li>保存您的进度，并在更换手机时恢复。</li>
<li>展示排行榜——您的昵称、头像与积分会在其中对其他玩家可见。</li>
<li>展示支持开发的广告，并修复故障。</li></ul>
<h2>5. 数据存储位置</h2><ul>
<li><strong>您的设备：</strong>设置、进度与上传的照片。</li>
<li><strong>我们的服务器（Supabase）：</strong>若您关联了 Google 账号，则包括进度与排名。</li>
<li><strong>运营合作方：</strong>Google（Play、AdMob、Firebase）及多人联机服务商。</li></ul>
<p>数据可能在您所在国家之外的服务器上处理，并适用相应服务商的政策。</p>
<h2>6. 我们共享什么</h2>
<p><strong>我们不出售您的数据，也不与广告商共享用于营销。</strong>仅在运营所必需的范围内与上述服务商共享，或在法律要求时共享。</p>
<h2>7. 儿童</h2>
<p>本游戏不面向 13 岁以下儿童，我们也不会在知情的情况下收集其数据。若您是监护人并认为孩子向我们提供了数据，请联系我们删除。</p>
<h2>8. 您的权利</h2><ul>
<li><strong>查阅</strong>我们所保存的有关您的数据。</li>
<li><strong>更正</strong>——在游戏内更改您的昵称与头像。</li>
<li><strong>删除</strong>——通过<a href="/delete">删除账号页面</a>。</li>
<li><strong>解除关联</strong>——游戏内的“解除 Google 关联”按钮。</li>
<li><strong>重置广告标识符</strong>——手机设置 → Google → 广告。</li></ul>
<h2>9. 数据保留</h2>
<p>账号存续期间我们保留您的数据。收到删除请求后将在 30 天内清除，法律要求保留的除外。</p>
<h2>10. 安全</h2>
<p>数据通过 HTTPS 加密传输，服务器隔离每位玩家的数据行，任何人都无法访问他人数据。但没有任何传输或存储方式是绝对安全的。</p>
<h2>11. 政策更新</h2><p>我们可能更新本政策，更新内容将在此页公布并更改“最后更新”日期。</p>
<h2>12. 联系方式</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`}
},

/* ═══════════════════ حذف الحساب ═══════════════════ */
del:{
ar:{title:'حذف الحساب والبيانات', body:`
<p>تطبيق <strong>Ronda Tahiro</strong> — المعرّف <code>com.rondatahiro.myapp</code> — من إنتاج <strong>Ahmed Bakkali Tahiri</strong>.</p>
<h2>الطريقة الأولى: من داخل اللعبة</h2><ul>
<li>افتح اللعبة ← شاشة الدخول ← اضغط <strong>«إلغاء الربط بـ Google»</strong>. يُنهي ذلك جلستك ويمسح بيانات حسابك من الجهاز.</li>
<li>ثم من إعدادات هاتفك: <strong>الإعدادات ← التطبيقات ← Ronda Tahiro ← التخزين ← مسح البيانات</strong>.</li></ul>
<h2>الطريقة الثانية: حذف كامل من خوادمنا</h2>
<p>راسلنا من <strong>البريد نفسه المرتبط بحسابك في اللعبة</strong>:</p>
<p><a href="mailto:${MAIL}?subject=Delete%20Account%20-%20Ronda">${MAIL}</a></p>
<p>واكتب في الرسالة: الموضوع <strong>طلب حذف حساب</strong>، واسمك المستعار داخل اللعبة.</p>
<div class="note">نعالج الطلب ونؤكّده لك خلال <strong>30 يوماً</strong> على الأكثر.</div>
<h2>ما الذي يُحذف</h2><ul>
<li>حسابك وارتباطه بـ Google.</li>
<li>تقدّمك المحفوظ سحابياً: الذهب والجواهر والمستوى والإنجازات.</li>
<li>إحصائياتك وصفّك في لوحة الترتيب.</li>
<li>اسمك المستعار وصورتك.</li></ul>
<h2>ما قد يبقى</h2><ul>
<li>سجلّات تقنية مجهّلة الهوية لا تدلّ عليك.</li>
<li>نسخ احتياطية تُمحى تلقائياً خلال 90 يوماً.</li>
<li>بيانات تفرض القوانين الاحتفاظ بها.</li></ul>
<h2>تنبيه</h2>
<p>الحذف <strong>نهائي ولا يمكن التراجع عنه</strong>. سيفقد الحساب كل تقدّمه وعملاته وترتيبه.</p>
<h2>التواصل</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`},

en:{title:'Account & Data Deletion', body:`
<p><strong>Ronda Tahiro</strong> — package <code>com.rondatahiro.myapp</code> — developed by <strong>Ahmed Bakkali Tahiri</strong>.</p>
<h2>Option 1: from inside the game</h2><ul>
<li>Open the game → login screen → tap <strong>"Unlink Google"</strong>. This ends your session and clears your account data from the device.</li>
<li>Then on your phone: <strong>Settings → Apps → Ronda → Storage → Clear data</strong>.</li></ul>
<h2>Option 2: full deletion from our servers</h2>
<p>Email us from <strong>the same address linked to your game account</strong>:</p>
<p><a href="mailto:${MAIL}?subject=Delete%20Account%20-%20Ronda">${MAIL}</a></p>
<p>Include: subject <strong>Delete account request</strong>, and your in-game nickname.</p>
<div class="note">We process and confirm your request within <strong>30 days</strong> at most.</div>
<h2>What gets deleted</h2><ul>
<li>Your account and its Google link.</li>
<li>Your cloud-saved progress: coins, gems, level and achievements.</li>
<li>Your statistics and leaderboard entry.</li>
<li>Your nickname and photo.</li></ul>
<h2>What may remain</h2><ul>
<li>Anonymised technical logs that cannot identify you.</li>
<li>Backups, erased automatically within 90 days.</li>
<li>Data the law requires us to keep.</li></ul>
<h2>Warning</h2>
<p>Deletion is <strong>permanent and cannot be undone</strong>. The account loses all progress, currency and ranking.</p>
<h2>Contact</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`},

es:{title:'Eliminación de cuenta y datos', body:`
<p><strong>Ronda Tahiro</strong> — paquete <code>com.rondatahiro.myapp</code> — desarrollado por <strong>Ahmed Bakkali Tahiri</strong>.</p>
<h2>Opción 1: desde el juego</h2><ul>
<li>Abre el juego → pantalla de acceso → pulsa <strong>«Desvincular Google»</strong>. Esto cierra tu sesión y borra los datos de la cuenta del dispositivo.</li>
<li>Después, en tu teléfono: <strong>Ajustes → Aplicaciones → Ronda → Almacenamiento → Borrar datos</strong>.</li></ul>
<h2>Opción 2: eliminación completa de nuestros servidores</h2>
<p>Escríbenos desde <strong>la misma dirección vinculada a tu cuenta</strong>:</p>
<p><a href="mailto:${MAIL}?subject=Delete%20Account%20-%20Ronda">${MAIL}</a></p>
<p>Incluye: asunto <strong>Solicitud de eliminación de cuenta</strong> y tu apodo en el juego.</p>
<div class="note">Procesamos y confirmamos la solicitud en un plazo máximo de <strong>30 días</strong>.</div>
<h2>Qué se elimina</h2><ul>
<li>Tu cuenta y su vínculo con Google.</li>
<li>Tu progreso guardado en la nube: monedas, gemas, nivel y logros.</li>
<li>Tus estadísticas y tu entrada en la clasificación.</li>
<li>Tu apodo y tu foto.</li></ul>
<h2>Qué puede permanecer</h2><ul>
<li>Registros técnicos anonimizados que no permiten identificarte.</li>
<li>Copias de seguridad, borradas automáticamente en 90 días.</li>
<li>Datos que la ley obliga a conservar.</li></ul>
<h2>Aviso</h2>
<p>La eliminación es <strong>permanente e irreversible</strong>. La cuenta pierde todo su progreso, monedas y clasificación.</p>
<h2>Contacto</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`},

zh:{title:'删除账号与数据', body:`
<p><strong>Ronda Tahiro</strong> —— 包名 <code>com.rondatahiro.myapp</code> —— 由 <strong>Ahmed Bakkali Tahiri</strong> 开发。</p>
<h2>方式一：在游戏内操作</h2><ul>
<li>打开游戏 → 登录界面 → 点击<strong>“解除 Google 关联”</strong>。这将结束会话并清除设备上的账号数据。</li>
<li>然后在手机上：<strong>设置 → 应用 → Ronda → 存储 → 清除数据</strong>。</li></ul>
<h2>方式二：从我们的服务器彻底删除</h2>
<p>请使用<strong>与游戏账号关联的同一邮箱</strong>发送邮件至：</p>
<p><a href="mailto:${MAIL}?subject=Delete%20Account%20-%20Ronda">${MAIL}</a></p>
<p>请注明：主题<strong>删除账号请求</strong>，以及您的游戏昵称。</p>
<div class="note">我们将在最多 <strong>30 天</strong>内处理并向您确认。</div>
<h2>将被删除的内容</h2><ul>
<li>您的账号及其 Google 关联。</li>
<li>云端保存的进度：金币、宝石、等级与成就。</li>
<li>您的统计数据与排行榜记录。</li>
<li>您的昵称与头像。</li></ul>
<h2>可能保留的内容</h2><ul>
<li>无法识别您身份的匿名技术日志。</li>
<li>备份数据，将在 90 天内自动清除。</li>
<li>法律要求保留的数据。</li></ul>
<h2>提示</h2>
<p>删除操作<strong>不可撤销</strong>。账号将失去全部进度、货币与排名。</p>
<h2>联系方式</h2><p><a href="mailto:${MAIL}">${MAIL}</a></p>`}
}
};

/* ── كشف اللغة وعرض الصفحة ───────────────────────────────── */
const LANGS = ['ar','en','es','zh'];
const LBL   = { ar:'العربية', en:'English', es:'Español', zh:'中文' };

function pickLang(){
  try{
    const saved = localStorage.getItem('ronda_site_lang');
    if(saved && LANGS.indexOf(saved) >= 0) return saved;
  }catch(e){}
  // لغة الجهاز: navigator.languages يحترم ترتيب تفضيل المستخدم
  const list = (navigator.languages && navigator.languages.length)
    ? navigator.languages : [navigator.language || 'en'];
  for(const l of list){
    const c = String(l).toLowerCase();
    if(c.startsWith('ar')) return 'ar';
    if(c.startsWith('es')) return 'es';
    if(c.startsWith('zh')) return 'zh';
    if(c.startsWith('en')) return 'en';
  }
  return 'en';
}

function renderLegal(docKey){
  const lang = pickLang();
  const u = UI[lang], d = LEGAL[docKey][lang];
  document.documentElement.lang = lang;
  document.documentElement.dir  = u.dir;
  document.title = d.title + ' — Ronda Tahiro';

  const back = document.getElementById('backLink');
  if(back) back.textContent = u.back;

  const sw = document.getElementById('langSwitch');
  if(sw){
    sw.innerHTML = LANGS.map(l =>
      `<button class="lang-btn${l===lang?' on':''}" data-l="${l}"
        aria-pressed="${l===lang}" lang="${l}">${LBL[l]}</button>`).join('');
    sw.querySelectorAll('.lang-btn').forEach(b=>{
      b.addEventListener('click',()=>{
        try{ localStorage.setItem('ronda_site_lang', b.dataset.l); }catch(e){}
        renderLegal(docKey);
      });
    });
  }

  const art = document.getElementById('doc');
  if(art) art.innerHTML =
      `<h1>${d.title}</h1>`
    + `<p class="updated">${u.updated}: ${UPDATED[lang]}</p>`
    + d.body;

  const nav = document.getElementById('footNav');
  if(nav) nav.innerHTML =
      `<a href="/">${u.home}</a>`
    + `<a href="/privacy">${u.privacy}</a>`
    + `<a href="/terms">${u.terms}</a>`
    + `<a href="/delete">${u.del}</a>`;
}
