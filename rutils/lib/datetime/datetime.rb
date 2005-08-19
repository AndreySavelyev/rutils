require 'date'

module RuTils
	module DateTime
		def self.distance_of_time_in_words(from_time, to_time = 0, include_seconds = false, absolute = false) #nodoc
			from_time = from_time.to_time if from_time.respond_to?(:to_time)
			to_time = to_time.to_time if to_time.respond_to?(:to_time)
			distance_in_minutes = (((to_time - from_time).abs)/60).round
			distance_in_seconds = ((to_time - from_time).abs).round

			case distance_in_minutes
				when 0..1
					return (distance_in_minutes==0) ? 'меньше минуты' : '1 минуту' unless include_seconds

				case distance_in_seconds
					 when 0..5	 then 'менее чем 5 секунд'
					 when 6..10	 then 'менее чем 10 секунд'
					 when 11..20 then 'менее чем 20 секунд'
					 when 21..40 then 'пол-минуты'
					 when 41..59 then 'меньше минуты'
					 else					'1 минуту'
				 end
														 
				 when 2..45			 then distance_in_minutes.items(2, "минута", "минуты", "минут") 
				 when 46..90		 then 'около часа'
				 when 90..1440	 then "около " + (distance_in_minutes.to_f / 60.0).round.items(1, "час", "часа", "часов")
				 when 1441..2880 then '1 день'
				 else									(distance_in_minutes / 1440).round.items(1,"день", "дня", "дней")
			 end
		end
		
	end
end

class RuTils::DateTime::RussianDate < Date
	  # Full month names, in English.  Months count from 1 to 12; a
	  # month's numerical representation indexed into this array
	  # gives the name of that month (hence the first element is nil).
	  MONTHNAMES = [nil] + %w(Январь Февраль Март Апрель Май Июнь Июль
				  Август Сентябрь Октябрь Ноябрь Декабрь)

	  # Full names of days of the week, in English.  Days of the week
	  # count from 0 to 6 (except in the commercial week); a day's numerical
	  # representation indexed into this array gives the name of that day.
	  DAYNAMES = %w(Воскресенье Понедельник Вторник Среда Четверг Пятница Суббота)

	  # Abbreviated month names, in English.
	  ABBR_MONTHNAMES = [nil] + %w(Янв Фев Мар Апр Май Июнь
				       Июль Авг Сен Окт Ноя Дек)
	  # Abbreviated day names, in English.
	  ABBR_DAYNAMES = %w(Вск Пн Вт Ср Чт Пт Сб)

end

class Date
	def ru_strftime(*args)
		RuTils::DateTime::RussianDate.new(self).strftime(*args)
	end
end