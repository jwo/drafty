namespace :drafty do

  task :export => :environment do
    File.open("output.json", "wb") {|f| f << Player.all.to_json }
  end

  desc 'import CSV files'
  task :import => :environment do
    puts "Importing"
    Player.destroy_all

    { :qb => "qb.xlsx",
             :rb => "rb.xlsx",
              :wr => "wr.xlsx",
              :te => "te.xlsx",
    }.each do |position, filename|

        spreadsheet = Roo::Excelx.new("#{Rails.root + "lib/tasks/" + filename}", file_warning: :ignore)

        map = {}

        # replace here with roo gem
        header = spreadsheet.row(1).select(&:present?).map{|k| k.parameterize.underscore.to_sym}
        header.each_with_index do |symbol, i|
          map[symbol] = i
        end


        (2..spreadsheet.last_row).each do |i|
          row = spreadsheet.row(i)
          new_attrs = {}

          fields = Player.new.attributes.keys.collect { |key| key.to_sym }
          [:id, :created_at, :updated_at].flatten.each do |key|
            fields.delete(key)
          end
          fields.each do |key|
            new_attrs[key] = row[map[key]] if map[key]
          end

          item = Player.new(new_attrs)
          item.position = position

          if item.valid?
            item.save!
          else
            puts item.inspect
          end

        end

    end

  end

end
