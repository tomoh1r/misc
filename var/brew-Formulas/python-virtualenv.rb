class PythonVirtualenv < Formula
  homepage "https://virtualenv.pypa.io/"
  url "https://pypi.python.org/packages/source/v/virtualenv/virtualenv-13.0.3.tar.gz"
  version "13.0.3"
  sha1 "8cd0bbc84d4cc99e72eca483912bcdf7ed384c17"

  depends_on :python if MacOS.version <= :snow_leopard

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system bin/"virtualenv", testpath/"venv"
  end
end
