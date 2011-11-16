# encoding: utf-8
require 'spec_helper'

describe TypographerHelper, 'with typographer' do
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ERB::Util

  it "should have t helper" do
    ty('typographer me please').should == 'typographer me&nbsp;please'
  end

  it "should typographer output of h helper" do
    h('Typographer & &amp;').should == 'Typographer &amp; &amp;amp;'
  end

  it "should work with custom-added formats" do
    TypographerHelper.register(:simple, [TypographerHelper::Parsers::SimpleFormat, TypographerHelper::Parsers::Basic])
    ty("I'm first\n\nAnd I&nbsp;am&nbsp;second", :simple).should == "<p>I&#146;m first</p>\n\n<p>And I&nbsp;am&nbsp;second</p>"
  end

  it "should return '<p></p>' (simple_format of empty string) on simple_format(nil)" do
    simple_format(nil).should == "<p></p>"
  end

  it "should make russian quotes for quotes with first russian letter" do
    ty('"текст"').should == '&laquo;текст&raquo;'
    ty('Text "текст" text').should == 'Text &laquo;текст&raquo; text'
    ty('Text "текст" text "Другой текст" ').should == 'Text &laquo;текст&raquo; text &laquo;Другой текст&raquo; '
  end

  it "should make russian quotes for quotes with first russian letter, beginning with html tag" do
    ty('"<a href="#link">те</a>кст"').should == '&laquo;<a href="#link">те</a>кст&raquo;'
    ty('Text "<b>те</b>кст" text').should == 'Text &laquo;<b>те</b>кст&raquo; text'
  end

  it "should make russian quotes for quotes with html tag" do
    ty('Текст "Начало текста <a href="#link">те</a>кст"').should == 'Текст &laquo;Начало текста <a href="#link">те</a>кст&raquo;'
  end

  it "should do the same with single quotes" do
    ty('\'текст\'').should == '&laquo;текст&raquo;'
    ty('Text \'текст\' text').should == 'Text &laquo;текст&raquo; text'
    ty('Text \'текст\' text \'Другой текст\' ').should == 'Text &laquo;текст&raquo; text &laquo;Другой текст&raquo; '
  end

  it "should create second-level russian quotes" do
   ty('Текст "в кавычках "второго уровня""').should == 'Текст &laquo;в&nbsp;кавычках &#132;второго уровня&#147;&raquo;'
  end

  it "should make english quotes for quotes with first non-russian letter" do
    ty('"text"').should == '&#147;text&#148;'
    ty('Text "text" text').should == 'Text &#147;text&#148; text'
    ty('Text "text" text "Another text" ').should == 'Text &#147;text&#148; text &#147;Another text&#148; '
  end

  it "should do the same with single quotes" do
    ty('\'text\'').should == '&#147;text&#148;'
    ty('Text \'text\' text').should == 'Text &#147;text&#148; text'
    ty('Text \'text\' text \'Another text\' ').should == 'Text &#147;text&#148; text &#147;Another text&#148; '
  end

  it "should create second-level english quotes" do
    ty('Text "in quotes "second level""').should == 'Text &#147;in&nbsp;quotes &#145;second level&#146;&#148;'
  end


  it "should not replace quotes inside html tags" do
    ty('<a href="ссылка">ссылка</a>').should == '<a href="ссылка">ссылка</a>'
    ty('<a href=\'ссылка\'>"ссылка"</a>').should == '<a href=\'ссылка\'>&laquo;ссылка&raquo;</a>'

    ty('<a href=\'link\'>link</a>').should == '<a href=\'link\'>link</a>'
    ty('<a href="link">"link"</a>').should == '<a href="link">&#147;link&#148;</a>'

    ty(' one">One</a> <a href="two"></a> <a href="three" ').should == ' one">One</a> <a href="two"></a> <a href="three" '
  end

  it "should make english and russian quotes in the same string" do
    ty('"Кавычки" and "Quotes"').should == '&laquo;Кавычки&raquo; and &#147;Quotes&#148;'
    ty('"Quotes" и "Кавычки"').should == '&#147;Quotes&#148; и&nbsp;&laquo;Кавычки&raquo;'

    ty('"Кавычки "второго уровня"" and "Quotes "second level""').should == '&laquo;Кавычки &#132;второго уровня&#147;&raquo; and &#147;Quotes &#145;second level&#146;&#148;'
    ty('"Quotes "second level"" и "Кавычки "второго уровня""').should == '&#147;Quotes &#145;second level&#146;&#148; и&nbsp;&laquo;Кавычки &#132;второго уровня&#147;&raquo;'
  end

  it "should make (“”) quotes in the same string" do
    ty('“Кавычки” and “Quotes”').should == '&#132;Кавычки&#147; and &#132;Quotes&#147;'
  end

  it "should replace -- to &mdash;" do
    ty('Replace -- to mdash please').should == 'Replace&nbsp;&mdash; to&nbsp;mdash please'
  end

  it "should replace \"word - word\" to \"word&nbsp;&mdash; word\"" do
    ty('word - word').should == 'word&nbsp;&mdash; word'
  end

  it "should insert &nbsp; before each &mdash; if it has empty space before" do
    ty('Before &mdash; after').should == 'Before&nbsp;&mdash; after'
    ty('Before	 &mdash; after').should == 'Before&nbsp;&mdash; after'
    ty('Before&mdash;after').should == 'Before&mdash;after'
  end


  it "should insert &nbsp; after small words" do
    ty('an apple').should == 'an&nbsp;apple'
  end

  it "should insert &nbsp; after small words" do
    ty('I want to be a scientist').should == 'I&nbsp;want to&nbsp;be&nbsp;a&nbsp;scientist'
  end

  it "should insert &nbsp; after small words with ( or dash before it" do
    ty('Apple (an orange)').should == 'Apple (an&nbsp;orange)'
  end

  it "should not insert &nbsp; after small words if it has not space after" do
    ty('Хорошо бы.').should == 'Хорошо бы.'
    ty('Хорошо бы').should == 'Хорошо бы'
    ty('Хорошо бы. Иногда').should == 'Хорошо бы. Иногда'
  end

  it "should insert <span class=\"nobr\"></span> around small words separated by dash" do
    ty('Мне фигово что-то').should == 'Мне фигово <span class="nobr">что-то</span>'
    ty('Как-то мне плохо').should == '<span class="nobr">Как-то</span> мне плохо'
    ty('хуе-мое').should == '<span class="nobr">хуе-мое</span>'
  end

  it "should not insert <span class=\"nobr\"></span> around words separated by dash if both of them are bigger than 3 letters" do
    ty('мальчик-девочка').should == 'мальчик-девочка'
  end

  it "should replace single quote between letters to apostrophe" do
    ty('I\'m here').should == 'I&#146;m here'
  end


  it "should typographer real world examples" do
    ty('"Читаешь -- "Прокопьев любил солянку" -- и долго не можешь понять, почему солянка написана с маленькой буквы, ведь "Солянка" -- известный московский клуб."').should == '&laquo;Читаешь&nbsp;&mdash; &#132;Прокопьев любил солянку&#147;&nbsp;&mdash; и&nbsp;долго не&nbsp;можешь понять, почему солянка написана с&nbsp;маленькой буквы, ведь &#132;Солянка&#147;&nbsp;&mdash; известный московский клуб.&raquo;'
  end

  it "should typographer real world examples" do
    ty('"Заебалоооооо" противостояние образует сет, в частности, "тюремные психозы", индуцируемые при различных психопатологических типологиях.').should == '&laquo;Заебалоооооо&raquo; противостояние образует сет, в&nbsp;частности, &laquo;тюремные психозы&raquo;, индуцируемые при различных психопатологических типологиях.'
  end

  it "should typographer real world examples" do
    ty('"They are the most likely habitat that we\'re going to get to in the foreseeable future," said NASA Ames Research Center\'s Aaron Zent, the lead scientist for the probe being used to look for unfrozen water.').should == '&#147;They are the most likely habitat that we&#146;re going to&nbsp;get to&nbsp;in&nbsp;the foreseeable future,&#148; said NASA Ames Research Center&#146;s Aaron Zent, the lead scientist for the probe being used to&nbsp;look for unfrozen water.'
  end

  it "should typographer real wordl examples" do
    ty('Фирменный стиль: от полиграфии к интернет-решениям (в рамках выставки «Дизайн и Реклама 2009»)').should == 'Фирменный стиль: от&nbsp;полиграфии к&nbsp;интернет-решениям (в&nbsp;рамках выставки «Дизайн и&nbsp;Реклама 2009»)'
  end

  it "should typographer real world examples" do
    ty('решениям (в рамках выставки').should == 'решениям (в&nbsp;рамках выставки'
  end

  it "should typographer real world examples" do
    ty('Реанимация живописи: «новые дикие» и «трансавангард» в ситуации арт-рынка 1980-х').should == 'Реанимация живописи: «новые дикие» и&nbsp;«трансавангард» в&nbsp;ситуации арт-рынка <span class="nobr">1980-х</span>'
  end

  it "should typographer real world examples" do
    ty('«Искусство после философии&raquo; – концептуальные стратегии Джозефа Кошута и Харальда Зеемана').should == '«Искусство после философии&raquo;&nbsp;&mdash; концептуальные стратегии Джозефа Кошута и&nbsp;Харальда Зеемана'
  end

  it "should typographer real world examples" do
    ty('Испанцы говорят, что целовать мужчину без усов, - всё равно что есть яйцо без соли').should == 'Испанцы говорят, что целовать мужчину без усов,&nbsp;&mdash; всё равно что есть яйцо без соли'
  end

  it "should typographer nested quotes properly" do
    text = %{<p>&quot;Кто-то прибежал&quot; Кто-то прибежал Кто-то прибежал Кто-то прибежал Кто-то прибежал Кто-то прибежал Кто-то прибежал Кто-то прибежал Кто-то прибежал</p><p>&quot;Кто-то прибежал Кто-то прибежал&quot; &nbsp;Кто-то прибежал &laquo;Кто-то прибежал К&raquo;</p>}
    expected_text = %{<p>&laquo;Кто-то прибежал&raquo; <span class=\"nobr\">Кто-то</span> прибежал <span class=\"nobr\">Кто-то</span> прибежал <span class=\"nobr\">Кто-то</span> прибежал <span class=\"nobr\">Кто-то</span> прибежал <span class=\"nobr\">Кто-то</span> прибежал <span class=\"nobr\">Кто-то</span> прибежал <span class=\"nobr\">Кто-то</span> прибежал <span class=\"nobr\">Кто-то</span> прибежал</p><p>&laquo;Кто-то прибежал <span class=\"nobr\">Кто-то</span> прибежал&raquo; &nbsp;Кто-то прибежал &laquo;Кто-то прибежал К&raquo;</p>}
    ty(text).should == expected_text
  end

  it "should typographer nested quotes properly on real-world examples" do
    text = %{<p>Об очередном ляпе &laquo;налоговой библии&raquo; пишет в своей статье для &laquo;ЗН в Украине&raquo; пишет кандидат юридических наук, доцент кандидат юридических наук, доцент Данил Гетманцев.</p><p>&laquo;Даже при последующем выполнении плательщиком требований налоговой службы его счета будут находиться под арестом&raquo;</p>}
    expected_text = %{<p>Об очередном ляпе &laquo;налоговой библии&raquo; пишет в&nbsp;своей статье для &laquo;ЗН&nbsp;в&nbsp;Украине&raquo; пишет кандидат юридических наук, доцент кандидат юридических наук, доцент Данил Гетманцев.</p><p>&laquo;Даже при последующем выполнении плательщиком требований налоговой службы его счета будут находиться под арестом&raquo;</p>}
    ty(text).should == expected_text
  end

end

