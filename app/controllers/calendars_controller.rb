class CalendarsController < ApplicationController

  # １週間のカレンダーと予定が表示されるページ
  def index
    get_week
    @plan = Plan.new
  end

  # 予定の保存
  def create
    Plan.create(plan_params)
    redirect_to action: :index
  end

  private

  def plan_params
    params.require(:plan).permit(:date, :plan)
  end

  def get_week
    wdays = ['(日)','(月)','(火)','(水)','(木)','(金)','(土)']

    # Dateオブジェクトは、日付を保持しています。下記のように`.today.day`とすると、今日の日付を取得できます。
    @todays_date = Date.today
    # 例)　今日が2月1日の場合・・・ Date.today.day => 1日
    # このDate.todayに今日の日付が入っており、それを@todays_dateに入れている。ここにプラスしてDate.today.wdayとすると、今日の曜日が入ることになる。となると、下のtimesメソッドの@todays + xのところで、曜日だけが入ってしまい、日付が入らなくなる。また、days = { :month => (@todays_date + x).month, :date => (@todays_date + x).day, :plans => today_plans}のところで、日付を処理している:date => (@todays_date + x).dayの部分で曜日が入ってしまい、おかしくなる。なので、ここは日付だけにしておいて、別のところで、Date.today.wdayを設定する。次はこの段階では何も代入していないwday_num =を見ていく。
    
    @week_days = []

    plans = Plan.where(date: @todays_date..@todays_date + 6)

    7.times do |x|
      # このxに0からの数値が入っている
      today_plans = []
      plans.each do |plan|
        today_plans.push(plan.plan) if plan.date == @todays_date + x
      end

      # ここでifによって適用されれば日付が一つ一つ入力されている。

      # 「その日以降の曜日」を一つ一つ取得するためには、7.times do ~ endの中でこの数値を変化させていく必要がある。具体的には、1回処理を繰り返す度に1ずつ数字を増やす。これで、正しい曜日の文字をセットしていくことができる。

      # wday_num = Date.today.wday
      # wdayメソッドを用いて取得した数値
      # Date.today.wdayはあくまでも今日の曜日の「数値」が取れるメソッドで、曜日自体の値（日曜や月曜などのこと）は取っていない。曜日自体の値を取っているのはwdays = ['(日)','(月)','(火)','(水)','(木)','(金)','(土)']である。また、Date.today.wdayのままだと、繰り返しになるが、これは今日の曜日（数値）を取るので、このままでは今日の曜日だけをずっと取り続けることになる。また、Date.today.wday[0]のように数値を指定しても、ここでは日曜日だけが表示される。つまり、ここは1日分の情報が入っているだけである。
      
      wday_num = Date.today.wday + x
      # 上に書いてあったwday_num = Date.today.wdayのままだと今日の曜日だけが入ったままであった。ここに7.times do |x|のxを付け加える。すると下にあるifの条件がうまく作動する。


      if wday_num >= 7 #「wday_numが7以上の場合」という条件式
        wday_num = wday_num -7
        # ここの処理はwday_numが7を含む数値以上になった場合（今回はwday_numの中身がwday_num = Date.today.wday + xによって、今日の曜日から一つずつ増えている）、wday_num = wday_num -7の右辺で7個引かれるという動きをしている。今回はwday_num >= 7というように、>に=がついているため、wday_numが7になった段階で7個引かれる設定となり、0となるから日曜日が出力される設定になっている。その処理が終わった後で、wday_num = wday_num -7の左辺が下にある[wday_num]の中に入っている。
      end

      # days = { :month => (@todays_date + x).month, :date => (@todays_date + x).day, :plans => today_plans, :wday => wdays[wday_num + x] } # wdaysから値を取り出す記述
      # 「:wday => wdaysから値を取り出す記述」について、:wdayは1日分の曜日が入っているキーである。右側は表示されるバリューであり、仮に配列になっているwdaysとすると、七日分全ての曜日が出力されることになる。実際にしてみると、縦に日〜土の情報が出力されることになる。ここではこのwdaysの中から一つだけ取り出したいので、[]を使って指定する。指定先は[]に数値として働いているwdayだが、これはwday_num = Date.today.wdayとしてwday_numに代入されているので、指定先を[wday_num]とする。ただ、このままでは、今日の曜日を一つだけ取り出せたが、ずっと今日の曜日が続いているだけなので、日付が変わるごとに一つ一つズラしていく必要がある。そこで既に一つ一つズレている日付を設定された箇所をヒントにし、wdays[wday_num + x]としたが、金曜と土曜までしか表示されなかった。これは7.times do |x|で、7回の処理が終わった時、日付に関しては繰り返し処理をしているので続いていくが、曜日については特に設定していないので、7回の処理で終了してしまい、7番目の土曜日以降の情報がないため、表示されていなかった。だから、ここに+ xをするのではなく、処理は上から順にされるので、もっと上の方で処理ができないか見る必要がある。下にあるのは元に戻している状態である。

      days = { :month => (@todays_date + x).month, :date => (@todays_date + x).day, :plans => today_plans, :wday => wdays[wday_num] }

      @week_days.push(days)
    end
  end
end
