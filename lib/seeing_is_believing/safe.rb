# require this before anything else, b/c it expects the world to be sane when it is loaded
class SeeingIsBelieving
  module Safe
    refine ::Queue do
      alias << <<
      alias shift shift
      alias clear clear
    end

    refine ::IO do
      alias sync= sync=
      alias << <<
      alias flush flush
      alias close close
    end

    refine ::Symbol do
      alias == ==
      alias to_s to_s
      alias inspect inspect
    end

    refine ::Symbol.singleton_class do
      alias define_method define_method
      alias class_eval class_eval
    end

    refine ::String do
      alias to_s to_s
    end

    refine ::Fixnum do
      alias to_s to_s
    end

    # to_s
    refine ::Array do
      alias pack pack
      alias map map
      alias size size
      alias join join
    end

    refine ::Hash do
      alias [] []
      alias []= []=
    end

    refine ::Hash.singleton_class do
      alias new new
    end

    refine ::Marshal.singleton_class do
      alias dump dump
    end

    refine ::Exception do
      alias message message
      alias backtrace backtrace
      alias class class
    end

    refine ::Exception.singleton_class do
      alias define_method define_method
      alias class_eval class_eval
    end

    refine ::Thread do
      alias join join
    end

    refine ::Thread.singleton_class do
      alias current current
    end
  end
end
