require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  INSERTION_SQL = "INSERT INTO students (name, grade) VALUES (?, ?)"
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id: nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute(INSERTION_SQL, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    DB[:conn].execute(INSERTION_SQL, name, grade)
    Student.new(name, grade, id: DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0])
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    Student.new(name, grade, id: id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
