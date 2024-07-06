class GenerateAst
    def main()
        if ARGV.size != 1
            puts "Usage: generate_ast <output directory>"
            exit(64)
        end
        output_dir = ARGV[0]
        expr_types = {
            "Assign" => {
                "name" => "Token",
                "value" => "Expr"
            },
            "Binary" => {
                "left" => "Expr",
                "operator" => "Token",
                "right" => "Expr"
            },
            "Grouping" => {
                "expression" => "Expr"
            },
            "Literal" => {
                "value" => "LiteralObject"
            },
            "Logical" => {
                "left" => "Expr",
                "operator" => "Token",
                "right" => "Expr"
            },
            "Unary" => {
                "operator" => "Token",
                "right" => "Expr"
            },
            "Variable" => {
                "name" => "Token"
            }
        }
        define_ast(output_dir, "Expr", expr_types)

        stmt_types = {
            "Block" => {
                "statements" => "Array(Stmt)"
            },
            "Expression" => {
                "expression" => "Expr"
            },
            "If" => {
                "condition" => "Expr",
                "then_branch" => "Stmt",
                "else_branch" => "Stmt | Nil",
            },
            "Print" => {
                "expression" => "Expr"
            },
            "Var" => {
                "name" => "Token",
                "initializer" => "Expr | Nil"
            },
            "While" => {
                "condition" => "Expr",
                "body" => "Stmt"
            }
        }
        define_ast(output_dir, "Stmt", stmt_types)
    end

    def define_ast(output_dir, base_name, types)
        path = "#{output_dir}/#{base_name.downcase}.cr"
        File.open(path, "w") do |file|
            file.puts("abstract class #{base_name}")

            define_visitor(file, base_name, types)

            # AST classes
            types.each do |class_name, fields|
                define_type(file, base_name, class_name, fields)
            end
            
            # Visitor accept method
            file.puts("  abstract def accept(visitor : Visitor(T))")

            file.puts("end")
        end
    end

    def define_type(file, base_name, class_name, fields)
        file.puts("  class #{class_name} < #{base_name}")
        fields.each do |name, type|
            file.puts("    property #{name} : #{type}")
        end
        params = fields.keys().map { |name| "@#{name}" }.join(", ")
        file.puts("    def initialize(#{params})")
        file.puts("    end")
        file.puts("    def accept(visitor : Visitor)")
        file.puts("      return visitor.visit_#{class_name.downcase}_#{base_name.downcase}(self)")
        file.puts("    end")
        file.puts("  end")
    end

    def define_visitor(file, base_name, types)
        file.puts("  module Visitor(T)")
        types.each_key do |class_name|
            file.puts("    abstract def visit_#{class_name.downcase}_#{base_name.downcase}(#{base_name.downcase} : #{class_name})")
        end
        file.puts("  end")
    end
end

ast_generator = GenerateAst.new
ast_generator.main()