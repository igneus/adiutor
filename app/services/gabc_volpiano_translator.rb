# Translates gabc to Volpiano.
class GabcVolpianoTranslator
  def call(gabc_source)
    r = nil
    Open3.popen3('python3', 'python/bin/gabc2volpiano.py') do |stdin, stdout, stderr, wait_thread|
      # chant21 crashes when parsing some headers and we don't really need them => strip them
      stdin.puts strip_gabc_header gabc_source
      stdin.close

      wait_thread.join
      status = wait_thread.value
      if status != 0
        raise "gabc to Volpiano conversion failed: #{stderr.read}"
      end

      r = stdout.read
    end

    r
  end

  private

  def strip_gabc_header(gabc_source)
    gabc_source.sub(/^.*(?=%%)/m, '')
  end
end
