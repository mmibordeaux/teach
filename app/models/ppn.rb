class PPN

  def self.parse
    doc = Nokogiri::HTML(HTML)

    objects = []

    (1..4).each do |index|
      Semester.find_or_create_by(number: index)
    end
    (1..2).each do |index|
      TeachingUnit.find_or_create_by(number: index)
    end

    # teaching_subject
    subjects = []
    doc.css('.element').each do |element|
      label = element.css('.name').first.content.to_s
      teaching_unit_number = element.css('.uevalue').first.content.to_i
      teaching_unit = TeachingUnit.where(number: teaching_unit_number).first
      TeachingSubject.find_or_create_by(label: label, teaching_unit_id: teaching_unit.id)
    end

    # teaching_category
    categories = []
    doc.css('.element .cat').each do |category|
      label = category.content.to_s
      TeachingCategory.find_or_create_by(label: label)
    end

    # Training modules
    doc.css('.element').each do |m|
      code = m.css('.id').first.content
      teaching_module = TeachingModule.find_or_create_by(code: code)
      teaching_module.label = m.css('.name').first.content
      teaching_module.semester_id = m.css('.semvalue').first.content.to_i
      teaching_unit_number = m.css('.uevalue').first.content.to_i
      teaching_unit = TeachingUnit.where(number: teaching_unit_number).first
      teaching_module.teaching_unit = TeachingUnit.where(number: teaching_unit_number).first
      teaching_subject_label = m.css('.name').first.content
      teaching_module.teaching_subject = TeachingSubject.where(label: teaching_subject_label, teaching_unit_id: teaching_unit.id).first
      teaching_category_label = m.css('.cat').first.content
      teaching_module.teaching_category = TeachingCategory.where(label: teaching_category_label).first
      teaching_module.coefficient = m.css('.coefvalue').first.content.to_i
      id = m.css('@href').first.content
      full_data = doc.css(id).first
      full_data.css('h3').each do |f|
        title = f.content
        nodes = []
        current = f.next_element
        while 
          nodes.push current
          current = current.next_element
          break if current.nil? or current.name == 'h3'
        end
        case title
          when 'Objectifs du module'
            nodes.collect(&:content).each do |objective_label|
              Objective.find_or_create_by(label: objective_label, teaching_module_id: teaching_module.id)
            end
          when 'Contenus'
            teaching_module.content = nodes.collect(&:content).join(' ')
          when 'Modalités de mise en œuvre'
            teaching_module.how_to = nodes.collect(&:content).join(' ')
          when 'Prolongements possibles'
            teaching_module.what_next = nodes.collect(&:content).join(' ')
          when 'Compétences visées'
            competencies = []
            if nodes.count == 1
              competency = nodes.first.content
              competency.gsub!('Être capable de ', '')
              competency.gsub!('Être capable d\'', '')
              competencies << competency
            else
              ul = nodes.pop
              ul.css('li').each do |li|
                competency_label = li.content
                Competency.find_or_create_by(label: competency_label, teaching_module_id: teaching_module.id)
              end
            end
          when 'Mots-clés'
            list = nodes.collect(&:content).join(',')
            list.gsub!("\r\n", ' ')
            list.gsub!("\n", ' ')
            list.gsub!("\r", ' ')
            list.gsub!("
", ' ')
            list.gsub!(" ; ", ',')
            list.gsub!('…', ',')
            list.gsub!('.', ',')
            list.gsub!('                                    ', '')
            list.gsub!(',,', ',')
            list.gsub!(', ', ',')
            list.gsub!('—', ',')
            list.gsub!(', ', ',')
            list.downcase!
            keywords = list.split(',')
            keywords.each do |keyword| 
              unless keyword.empty?
                Keyword.find_or_create_by(label: keyword, teaching_module_id: teaching_module.id)
              end
            end
          end
      end
      teaching_module.hours = full_data.css('.total').first.content.to_i
      teaching_module.save
      objects << teaching_module
    end
    objects
  end

  HTML =  %{
<!DOCTYPE html>
<html lang="fr">
<head>

  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Fiches modules</title>

  <!--[if lt IE 9]><script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script><![endif]-->

  <link rel="stylesheet" href="lib/css/isotope.css" />
  <link rel="stylesheet" href="lib/bootstrap/dist/css/bootstrap.min.css" />
  <link rel="stylesheet" href="lib/css/font-awesome.min.css" />
  <link rel="stylesheet" href="lib/css/docs.css" />
  <link rel="stylesheet" href="css/style.css" />
  
  <!-- scripts at bottom of page -->

</head>
<body>
  
  <header class="navbar navbar-inverse navbar-fixed-top bs-docs-nav" role="banner">
    <div class="container">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target=".bs-navbar-collapse">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <h2><a class="navbar-brand" href="index.html">PPN MMI</a></h2>
      </div>
      <nav class="collapse navbar-collapse bs-navbar-collapse" role="navigation">
        <ul class="nav navbar-nav">
          <li><a href="objectifs-formation.html">Objectifs</a></li>
          <li><a href="referentiel-activites-competences.html">Référentiel</a></li>
          <li><a href="organisation-generale-formation.html">Organisation</a></li>
          <li class="active"><a href="fiches-modules.html">Modules</a></li>
        </ul>
        <a href="ppn-mmi.zip" class="pull-right btn btn-success navbar-btn"><span class="glyphicon glyphicon-download"></span> Télécharger le PPN en HTML</a>
      </nav>
    </div>
  </header>

  <section id="content" class="fiches-modules container">
    <div class="row">
      <div class="col-md-3">
        <div class="bs-sidebar hidden-print affix" role="complementary">
          <ul class="nav bs-sidenav">
            <li class="option-combo semestre">
              <a>Semestres</a>
              <ul class="nav filter option-set" data-filter-group="semestre">
                <li><a class="selected" href="#filter-semestre-tous" data-filter-value="">Tous</a></li>
                <li><a href="#filter-semestre-s1" data-filter-value=".s1">Semestre 1</a></li>
                <li><a href="#filter-semestre-s2" data-filter-value=".s2">Semestre 2</a></li>
                <li><a href="#filter-semestre-s3" data-filter-value=".s3">Semestre 3</a></li>
                <li><a href="#filter-semestre-s4" data-filter-value=".s4">Semestre 4</a></li>
              </ul>
            </li>
            <li class="option-combo ue">
              <a>UE</a>
              <ul class="nav filter option-set" data-filter-group="ue"> 
                <li><a class="selected" href="#filter-ue-tout" data-filter-value="">Toutes</a></li>
                <li><a href="#filter-ue-ue1" data-filter-value=".ue1">UE1</a></li>
                <li><a href="#filter-ue-ue2" data-filter-value=".ue2">UE2</a></li>
              </ul>
            </li>
            <li class="option-combo categorie">
              <a>Catégorie</a>
              <ul class="nav filter option-set" data-filter-group="categorie"> 
                <li><a class="selected" href="#filter-cat-tout" data-filter-value="">Toutes</a></li>
                <li><a href="#filter-cat-communication" data-filter-value=".com">Com./écriture</a></li>
                <li><a href="#filter-cat-esth-video" data-filter-value=".esth-video">Esth./vidéo</a></li>
                <li><a href="#filter-cat-info-reseaux" data-filter-value=".info-reseaux">Info./réseaux</a></li>
                <li><a href="#filter-cat-transversal" data-filter-value=".trans">Transversal</a></li>
                <li><a href="#filter-cat-professionnalisation" data-filter-value=".prof">Professionnalisation</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
      
      <div class="col-md-9" role="main">
        <h1>Fiches modules</h1>
        <p>Les fiches indiquent pour chaque module de chaque semestre les objectifs à atteindre, les compétences devant
        être acquises ainsi que les contenus et des indications concernant les modalités de mise en oeuvre des
        enseignements.</p>

        <section id="options-2" class="clearfix combo-filters">
          
          <div class="option-combo tris">
              <div id="sort-by" class="btn-group option-set clearfix" data-option-key="sortBy">
                <a class="btn btn-default selected" href="#sortBy=original-order" data-option-value="original-order">Par défaut</a>
                <a class="btn btn-default" href="#sortBy=semestre" data-option-value="semvalue">semestre</a>
                <a class="btn btn-default" href="#sortBy=ue" data-option-value="uevalue">UE</a>
                <a class="btn btn-default" href="#sortBy=coef" data-option-value="coefvalue">Coef</a>
                <a class="btn btn-default" href="#sortBy=name"  data-option-value="name">Nom</a>
                <a class="btn btn-default" href="#sortBy=cat"  data-option-value="cat">Catégorie</a>
                <a class="btn btn-default" href="#sortBy=cm" data-option-value="cm">CM</a>
                <a class="btn btn-default" href="#sortBy=td" data-option-value="td">TD</a>
                <a class="btn btn-default" href="#sortBy=tp" data-option-value="tp">TP</a>
                <a class="btn btn-default" href="#sortBy=total" data-option-value="total">Total</a>
              </div>
          </div>
    
        </section> <!-- #options -->
    
        <div id="container" class="clearfix">
          <a data-toggle="modal" href="#m1101" class="element s1 ue1 m1101 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1101</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Anglais</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1101" tabindex="-1" role="dialog" aria-labelledby="m1101" aria-hidden="true">
                  <div class="modal-dialog">
                      <div class="modal-content">
                          <div class="modal-header">
                              <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                              <h4 class="modal-title">M1101 — Anglais S1</h4>
                          </div>
                          <div class="modal-body">
                            <table class="table table-striped table-bordered">
                              <thead>
                                <tr>
                                  <th>CM</th>
                                  <th>TD</th>
                                  <th>TP</th>
                                  <th>Total</th>
                                </tr>
                              </thead>
                              <tbody>
                                <tr>
                                  <td class="cm"></td>
                                  <td class="td">15</td>
                                  <td class="tp">15</td>
                                  <td class="total">30</td>
                                </tr>
                              </tbody>
                            </table>
                              <h3>Objectifs du module</h3>
                              <p>Prolonger les acquis de l’enseignement secondaire par l’élargissement des connaissances culturelles du monde anglo-saxon, particulièrement en ce qui concerne les TIC et le monde de l’entreprise, favoriser l’autonomie de l’étudiant en matière d’apprentissage de la langue.</p>
                              <p>Comprendre un langage clair et standard, connaître les possibilités des outils bibliographiques (dictionnaire, glossaire…) et savoir s’en servir pour assurer son autonomie.</p>
                              
                              <h3>Compétences visées</h3>
                              <p>Être capable de</p>
                              <ul>
                                <li>se présenter, de prendre part sans préparation à une conversation sur des sujets généraux et d’actualité, de donner son opinion et de restituer une information, en somme d’être interactif.</li>
                                <li>décrire à l’écrit et de manière cohérente des processus simples, de rédiger des écrits professionnels simples.</li>
                              </ul>
                              
                              <h3>Prérequis</h3>
                              <p>Enseignements d’adaptation de parcours ou résultats suffisants à l’évaluation.</p>
                              
                          <h3>Contenus</h3>
                          <p>Compréhension et analyse de l’actualité ou de faits de société en rapport avec l’informatique et le multimédia.</p>
                          <p>Anglais professionnel : se présenter – téléphoner – échanger des informations, rédiger un courriel ou un fax.</p>
                          <p>Anglais technique : comprendre et utiliser le vocabulaire des interfaces et de l’Internet.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Analyse de textes, commentaires, débats, prise de parole en continu ritualisée du type «5’ d’actualité», jeux de rôles, travail en tandem, en groupe, utilisation d’interfaces en langue anglaise, simulation de résolution de problème « en SAV ».</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Les enjeux de l’implémentation des TIC sur le lieu de travail – traductions techniques.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Prise de parole, revue de presse, monde de l’entreprise, TIC.</p>
                        </div>
                        <div class="modal-footer">
                          <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                        </div>
                      </div><!-- /.modal-content -->
                  </div><!-- /.modal-dialog -->
              </div>
          
          <a data-toggle="modal" href="#m1102" class="element s1 ue1 m1102 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M1102</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Langue vivante 2</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">20</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1102" tabindex="-1" role="dialog" aria-labelledby="m1102" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1102 — Langue vivante 2 S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm"></td>
                                <td class="td">10</td>
                                <td class="tp">10</td>
                                <td class="total">20</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Prolonger les acquis précédents dans la langue concernée et développer l’aisance dans la langue, tout en
                          intégrant la dimension interculturelle.</p>
                          <p>Avoir des notions de base de la communication interculturelle.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>appréhender des documents de nature variée.</li>
                              <li>produire un discours simple et cohérent sur des sujets familiers dans la langue cible.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>Avoir des notions de base dans la langue étrangère concernée et/ou avoir suivi les enseignements d’adaptation
                          de parcours.</p>
                          
                          <h3>Contenus</h3>
                          <p>Se présenter, décrire quelqu’un, trouver une information de la vie courante, étudier des modes de communication
                          interculturelle.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Simulations de situations de rencontres à l’étranger, d’utilisation du téléphone, des transports, travail en tandem,
                          échanges par courriel avec des partenaires étrangers, lecture d’un article de presse, commentaire d’un fait de
                          société.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Rédaction d’une courte biographie, d’un CV, d’une lettre formelle, d’une revue de presse.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Compréhension de l’oral, prise de parole.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1103" class="element s1 ue1 m1103 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M1103</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Théories de l'information et de la communication</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">10</td>
                  <td class="tp"></td>
                  <td class="total">20</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1103" tabindex="-1" role="dialog" aria-labelledby="m1103" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1103 — Théories de l'information et de la communication S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">10</td>
                                <td class="td">10</td>
                                <td class="tp"></td>
                                <td class="total">20</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Introduction à l’histoire des formes et techniques de communication numérique et aux notions théoriques de la
                          communication et de l’information.</p>
                          <p>Comprendre les grands enjeux économiques et sociaux de l’évolution contemporaine du champ de la
                          communication.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>replacer une activité de communication dans son contexte élargi.</li>
                            <li>maîtriser l’intérêt de la démarche théorique ; comprendre l’apport fondamental de la théorie à la technique ;
                          connaître les grandes lignes des développements techniques et de leur impact économique et social en matière
                          de communication ; savoir replacer de manière autonome des idées dans leur contexte théorique et historique.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Introduction à la société de l’information et de la connaissance. Introduction à la société de la communication, aux
                          utopies de la communication.</p>
                          <p>Histoire des techniques d'information et de communication : de l'écrit à l'imprimé, du papier au numérique ;
                          histoire des réseaux et de l'informatique ; le réseau Internet ; Théories et modèles de la communication et de
                          l’information mathématiques et cybernétiques ; Textes fondateurs de McLuhan; contre-culture et cyberculture ;
                          représentations médiatiques et culturelles des réseaux et d'Internet ; question des usages des technologies
                          numériques ; théories des réseaux sociaux ; question de l'homme amélioré, du post-humain, du robot androïde
                          (cyborg).</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Lecture des textes théoriques fondamentaux ; exposés de culture numérique ; fiches de lecture d'articles
                          théoriques ; fiches de lecture d’oeuvres de fiction ; diffusion de fictions filmiques/débats ; débats sur les usages
                          numériques...</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Il est envisageable/souhaitable d'articuler ces approches théoriques aux pratiques d'écritures pour les médias
                          numériques.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Société de l’information, société de la communication, utopies de la communication, société et
                          communication,histoire des formes et techniques de communication, théories mathématiques, théories
                          cybernétiques ; modèle orchestral, systémique ; rétroaction (feedback) ; entropie ; réseaux sociaux.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1104" class="element s1 ue1 m1104 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1104</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Esthétique et expression artistique</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">10</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1104" tabindex="-1" role="dialog" aria-labelledby="m1104" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1104 — Esthétique et expression artistique S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">10</td>
                                <td class="td">15</td>
                                <td class="tp">10</td>
                                <td class="total">35</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Acquérir une culture générale des arts à travers les différents courants artistiques.</p>
                          <p>Donner confiance en ses capacités créatives lorsque l’on n’a pas la maîtrise du geste.</p>
                          <p>Appréhender le langage visuel dans le but de communiquer clairement.</p>
                          <p>Développer le sens artistique et la créativité.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>mettre en oeuvre les fondamentaux du langage plastique et du langage filmique.</li>
                              <li>choisir les techniques de dessin, d'infographie, d'impression.</li>
                              <li>faire preuve d'invention et de créativité dans l'utilisation des outils.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Approche historique des arts graphiques et de la musique (les grands courants artistiques, les genres et les
                          styles, les éléments du langage musical, etc…).</p>
                          <p>Introduction à l’art contemporain / analyses.</p>
                          <p>Exploration de systèmes et d’outils de création graphique.</p>
                          <p>Étude des éléments graphiques de base (point, ligne, surface) et des éléments constituants de l’image (couleur,
                          composition, rapport texte et image, fond et forme).</p>
                          <p>Étude des modes de couleur et les espaces colorimétriques.</p>
                          <p>Hiérarchie de l'information par la composition (sens de lecture, rythmes, typographie, couleur…).</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Travail de création sur tous types de supports.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Analyse et conception de créations infographiques, de productions multimédias ou de compositions musicales.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Histoire de l’art, dessin, peinture, installation, infographie, performance, graphisme, photographie</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1105" class="element s1 ue1 m1105 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1105</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Écriture pour les médias numériques</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1105" tabindex="-1" role="dialog" aria-labelledby="m1105" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1105 — Écriture pour les médias numériques S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">10</td>
                                <td class="td">10</td>
                                <td class="tp">10</td>
                                <td class="total">30</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Analyser et Concevoir une interface (navigation, ergonomie, accessibilité).</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>élaborer un scénario en vue d'une production web ou multimédia.</li>
                              <li>savoir appliquer les fondements de l'ergonomie web et repérer les défauts d'utilisabilité d'une interface.</li>
                              <li>avoir une culture générale du multimédia.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Étude de sites internet et de productions multimédia pour mettre en évidence la scénarisation : la complexité du
                          lien entre l'information et la manière d'y accéder.</p>
                          <p>Approche de la scénarisation dans la démarche de projet multimédia; la place centrale de l'utilisateur dans la
                          production du modèle conceptuel d'un site web : les moyens de modéliser son usage (persona).</p>
                          <p>Savoir concevoir une interface ergonomique et fonctionnelle en utilisant des méthodes de conception (maquette
                          conceptuelle, maquette fonctionnelle, prototypage, etc.).</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Analyses de sites, production de scénarios.</p>
                          <p>Analyse de l'ergonomie d'un site web (test utilisateur, tri par cartes...) : repérage des points forts et des points
                          faibles, préconisations d'améliorations.</p>
                          <p>Analyse de sites e-commerce (fiche produits, processus achat, panier) : répérer les points forts et les points
                          faibles, faire des préconisation d'améliorations.</p>
                          <p>Conception de la maquette (zonings, wireframes) en vue de la réalisation d'un mini site web.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Traduction du concept et du scénario multimédia en une première représentation visuelle dans le cadre de la
                          conception de maquettes web.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Écriture, projet multimédia, utilisateur, e-commerce, ergonomie, accessibilité.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1106" class="element s1 ue1 m1106 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">3</span></p>
              <p class="id">M1106</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Communication, expression écrite et orale</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">20</td>
                  <td class="tp">15</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1106" tabindex="-1" role="dialog" aria-labelledby="m1106" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1106 — Expression, communication écrite et orale S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">5</td>
                                <td class="td">20</td>
                                <td class="tp">15</td>
                                <td class="total">40</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Prendre conscience des enjeux de la communication</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>connaître et maîtriser les fondements et les codes de la communication.</li>
                              <li>s'exprimer clairement.</li>
                              <li>rechercher et sélectionner les informations et savoir rendre compte.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>Bonnes compétences linguistiques en français.</p>
                          
                          <h3>Contenus</h3>
                          <p>Les concepts de la communication (situation, type, fonctions du langage).</p>
                          <p>La communication verbale et non verbale.</p>
                          <p>Techniques de prise de parole, techniques de communication en public.</p>
                          <p>Initiation aux outils et techniques de recherche documentaire.</p>
                          <p>Renforcement des compétences linguistiques.</p>
                          <p>Initiation à la présentation de soi, à l'autoscopie, aux CV et lettres de motivation (notamment lorsqu'un stage est
                          prévu dès la première année de DUT).</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Exercices de communication écrite et orale:lecture rapide, reformulation, prise de notes, rédaction, courriers,
                          courriels, compte rendu, prises de parole (improvisées, exposés, présentation de soi,n téléphoniques).</p>
                          <p>Supports visuels : production (posters, tracts...) et exposé oral avec un logiciel de présentation.</p>
                          <p>Travail d'équipe.</p>
                          <p>Ateliers d'écriture, soutien orthographique et grammatical.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Bureautique, PPP, Projets tutorés</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Communication, culture, éthique de la communication, écrit et oral, verbal et non verbal, visuels, recherche
                          documentaire, rédaction, rédaction technique</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1107" class="element s1 ue1 m1107 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1107</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Gestion de projet</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">15</td>
                  <td class="tp">10</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1107" tabindex="-1" role="dialog" aria-labelledby="m1107" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1107 — Gestion de projet S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">10</td>
                                <td class="td">15</td>
                                <td class="tp">10</td>
                                <td class="total">30</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Permettre aux étudiants de choisir l’outil adapté à un besoin donné. Il s'agit de pour l'étudiant de comprendre
                          l'intérêt de mener une démarche construite de gestion de projet, et de savoir mettre en forme les documents
                          permettant de convaincre ensuite avec crédibilité les interlocuteurs et les partenaires.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>maîtriser les outils de base de la gestion de projet et d’identifier les contextes dans lesquels les mettre en
                            œuvre.</li>
                              <li>maîtriser les logiciels de façon à travailler de manière autonome et professionnelle, d’apprendre à rechercher
                              l’information, de mettre en place un système de veille informationnelle.</li>
                              <li>utiliser des outils bureautiques pour mettre en forme/en page selon les règles en vigueur.</li>
                              <li>communiquer et diffuser , à l'écrit et à l'oral, l'information selon les règles en vigueur.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>La démarche de projet : les acteurs de la gestion de projet : le maître d’ouvrage (le commanditaire), le maître
                          d’oeuvre, les sous traitants, comité de pilotage.</p>
                          <p>L’équipe projet : répartition des rôles, définition des tâches, planification et enchaînement, attribution des
                          ressources.</p>
                          <p>Le cahier des charges : analyse et compréhension des besoins du client.</p>
                          <p>La définition des tâches, planification et enchaînement, attribution des ressources.</p>
                          <p>Les outils d’ordonnancement : diagramme de Gantt, introduction aux méthodes agiles…</p>
                          <p>Les spécificités du projet multimédia : les applications au projet multimédia (connaissance du public cible, analyse
                          de l’existant, architecture de l’information, arborescence, charte graphique, ligne éditoriale, spécifications
                          techniques, mise en page ou à l’écran, lancement, référencement…).</p>
                          <p>Traitement de texte : au-delà des fonctions de base, maîtrise des fonctionnalités autorisant l’automatisation des
                          tâches, publipostage (traditionnel et électronique), styles (préparation des fichiers pour la publication assistée par
                          ordinateur), outils de correction (orthographique et grammaticale), mode plan, gestion des documents longs…
                          Courrier électronique : gestion des protocoles, des listes de distribution, des règles de réception et d’envoi, etc.
                          Tableur-grapheur : traitement d’informations sur tableur-grapheur dans le cadre d’applications relevant du
                          domaine de la spécialité MMI.</p>
                          <p>Logiciel de présentation : maîtrise de la mise à l’écran d’informations : choix judicieux en matière de typographie,
                          de couleurs, de graphisme, des animations, constructions de gabarits… Automatisation : mise en oeuvre de
                          modèles et mode masque.</p>
                          <p>Recherche d’information, veille informationnelle, travail partagé.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Recours à un logiciel de gestion de projet.</p>
                          <p>Utilisation d'une suite bureautique : il est important de ne pas se focaliser sur l’étude d’une suite bureautique ou
                          d’un logiciel particulier mais de permettre aux étudiants de s’adapter en axant l’étude sur les concepts plutôt que
                          sur les outils.</p>
                          <p>Les heures TD et TP doivent permettre aux étudiants d'utiliser en situation les outils adaptés.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Les échanges entre applications (objets de toute sorte) et le travail collaboratif peuvent trouver une application
                          concrète dans ce cadre. Une exploitation transversale (mathématiques, statistiques, économie, gestion…) des
                          outils bureautiques complétera ces propositions de formation.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Maître d’ouvrage, maître d’oeuvre, besoins, cahier des charges, Gantt, équipe, méthodes agiles
                          Traitement de texte, tableur, courrier électronique, présentation assistée par ordinateur, veille, recherche
                          d’informations</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1108" class="element s1 ue1 m1108 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M1108</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">PPP</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">20</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1108" tabindex="-1" role="dialog" aria-labelledby="m1108" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1108 — Projet Personnel et Professionnel S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm"></td>
                                <td class="td">10</td>
                                <td class="tp">10</td>
                                <td class="total">20</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Le module PPP du S1 permet de :</p>
                          <ul>
                            <li>découvrir l’amplitude des métiers et des environnements professionnels liés à I'internet et au multimédia,</li>
                            <li>appréhender la diversité des environnements professionnels, et leurs conditions d’exercice ; (savoirs, savoirfaire,
                          qualités-clefs des différents métiers ; qualités requises pour les exercer, compétences à acquérir… ),</li>
                            <li>identifier les parcours de formation permettant l’accès à ces métiers et postes de travail,</li>
                            <li>acquérir des connaissances et savoir-faire dans l’élaboration, la mise en oeuvre et la réalisation d’un projet
                          d’orientation, et/ou de formation professionnelle.</li>
                          </ul>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>rechercher de l'information sur les métiers, l'environnement professionnel et les parcours de formation.</li>
                              <li>structurer ces informations et appliquer les règles de l'ergonomie pour les organiser.</li>
                              <li>utiliser les réseaux stratégiques d'information et de mettre en place une démarche de veille.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Organisation d’interventions, conférences, événements, pour compléter la connaissance de l’environnement :
                          les métiers, leur évolution et leur contexte, les poursuites d’études envisageables,</p>
                          <p>Réalisation d’enquêtes métiers</p>
                          <p>Recherches documentaires</p>
                          <p>Présentation et appropriation des outils de bilan personnel, projet professionnel et techniques de recherche
                          d’emploi,</p>
                          <p>Travail personnalisé de l’étudiant avec tuteur-accompagnateur : analyse individuelle d’un secteur d’activité, autoévaluation,
                          rédaction d’un projet professionnel personnel, bilans d’expérience, etc.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>D’une façon générale, il s’agit de mettre l’étudiant en situation d’aller voir par lui-même, d’expérimenter afin de
                          construire sa propre connaissance et son point de vue, et de l’aider à produire ce point de vue. La restitution
                          pourra se faire devant un groupe d’étudiants afin d’enrichir leurs connaissances et de confronter leurs
                          représentations.</p>
                          <p>Il est recommandé de mettre en place un tuteur-accompagnateur par étudiant tout au long du semestre.</p>
                          <p>Un entretien individuel en début et en fin de semestre peut compléter l’accompagnement de l’étudiant.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Construire des liens transversaux avec les modules en particulier le(s) projet(s) et le stage.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>PPP, orientation, insertion professionnelle, parcours individualisé de formation.</p>
                          <p>métiers ; emploi ; activités professionnelles ; environnements professionnels ; conditions d’exercice ;
                          compétences ; projet ; démarche de choix personnel</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1109" class="element s1 ue1 m1109 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1109</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Environnement juridique, éco. et merca. des orga.</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">15</td>
                  <td class="td">15</td>
                  <td class="tp"></td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1109" tabindex="-1" role="dialog" aria-labelledby="m1109" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1109 — Environnement juridique, économique et mercatique des
                          organisations S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">15</td>
                                <td class="td">15</td>
                                <td class="tp"></td>
                                <td class="total">30</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>L’objectif de ce cours est de permettre à l’étudiant d’acquérir sous une forme simple et pratique, l’essentiel des
                          connaissances juridiques, économiques, et mercatiques de base.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>caractériser les entreprises et plus généralement les organisations selon différents critères.</li>
                              <li>appréhender les conditions de création et de développement des entreprises.</li>
                              <li>rechercher et de comprendre de la documentation juridique.</li>
                              <li>connaître les structures juridiques des entreprises et de repérer leurs critères de choix en fonction d'un contexte
                              donné.</li>
                              <li>comprendre la démarche de stratégie mercatique générale d'une entreprise, en apprécier les différentes
                              composantes et leur nécessaire cohérence.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>L’organisation judiciaire (les ordres juridiques, les procédures de règlement des litiges, le déroulement d’une
                          procédure) et les sources du droit (les sources écrites, non écrites, la jurisprudence, la hiérarchie et la
                          complémentarité des normes).</p>
                          <p>L'exploitation d’une documentation juridique (savoir mener une recherche documentaire et la comprendre grâce à
                          l'acquisition du vocabulaire de base)</p>
                          <p>L’entreprise, un système complexe : rôle, création de richesse, groupement humain, relations avec
                          l’environnement, culture d’entreprise.</p>
                          <p>Typologie des entreprises : dimension, domaines d’activité, critères de classification, statuts juridiques
                          La démarche mercatique générale, les étapes de la démarche mercatique, le plan stratégique.</p>
                          <p>Le plan de marchéage (« marketing mix »), le produit, l’innovation, la gamme, la mercatique des services, la
                          fixation des prix.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>A partir d’un schéma relatif à l’organisation judiciaire, définir et caractériser les différentes juridictions.</p>
                          <p>Partir de l’étude de l’histoire d’une entreprise pour mettre en évidence les évolutions et approcher les termes
                          abordés.</p>
                          <p>Préconisations : pour la partie droit : 10 heures CM et 5 heures TD ; pour la partie économie d'entreprise et
                          mercatique : 5 heures CM, 10 heures TD.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Prévoir des interviews en entreprise (voir lien avec PPP) et/ou des visites d’entreprises</p>
                          <p>Prévoir une visite au tribunal</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Juridiction, tribunal d’Instance et de Grande Instance, Cour d’appel, Cour de Cassation, loi, constitution, directive,
                          preuve, arrêt…</p>
                          <p>Diversité des entreprises, statut juridique, PME, organisation…</p>
                          <p>Mercatique, stratégie, les 4 « P », démarche stratégique, gamme…</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
          
          <a data-toggle="modal" href="#m1110" class="element s1 ue1 m1110 harm">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue"></span></p>
              <p class="id">M1110</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Adaptation de parcours</h2>
              <h3 class="cat">Harmonisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">5</td>
                  <td class="tp">10</td>
                  <td class="total">15</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1110" tabindex="-1" role="dialog" aria-labelledby="m1110" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1110 — Adaptation de parcours S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm"></td>
                                <td class="td">5</td>
                                <td class="tp">10</td>
                                <td class="total">15</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Apporter une réponse personnalisée aux besoins d'adaptation des étudiants concernant toutes les matières de
                          l'UE11.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>appliquer les méthodes du travail universitaire.</li>
                              <li>faire preuve d'autonomie dans les apprentissages des UE11, UE21, UE31 et UE41.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Méthodologie du travail universitaire ; plans ; prises de notes ; modes de lecture ; préparation d’une intervention
                          orale ; autonomie dans la stratégie de travail.</p>
                          <p>En fonction des besoins personnalisés des étudiants l'équipe pédagogique pourra proposer :</p>
                          <ul>
                            <li>de la remédiation,</li>
                            <li>un travail complémentaire.</li>
                          </ul>
                          <p>Les besoins seront identifiés par l'équipe pédagogique au fil des enseignements et amendés si nécessaire par la
                          suite.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Préconisation : 5h TD méthodologie du travail universitaire, 10h TP en travail thématique (ensemble des
                          disciplines de l'UE1).</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>—</p>
                          
                          <h3>Mots-clés</h3>
                          <p>—</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
                
          <a data-toggle="modal" href="#m1201" class="element s1 ue2 m1201 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">3</span></p>
              <p class="id">M1201</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Culture scientifique et traitement de l'info.</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">15</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">45</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1201" tabindex="-1" role="dialog" aria-labelledby="m1201" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1201 — Culture scientifique et traitement de l'information S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">15</td>
                                <td class="td">15</td>
                                <td class="tp">15</td>
                                <td class="total">45</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Fournir aux étudiants les bases mathématiques du traitement de l’information. Connaître les outils de base des
                          mathématiques du signal, la dualité temps fréquence.</p>
                          <p>Initier l’étudiant à la notion d’information et en particulier à la quantité d’information présente dans les signaux
                          audio-vidéo, la parole et les images et présenter les différents modes de représentation de l’information.</p>
                          <p>Appréhender les fonctions principales de systèmes audio-vidéo et de transmission. Présenter les propriétés
                          importantes des sources sonores et lumineuses. Présenter les caractéristiques principales des systèmes auditif et
                          visuel humains. Comprendre les solutions technologiques de différents systèmes audiovisuels.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de comprendre les principes de l'acquisition, du traitement, du stockage et de la transmission
                          d'informations numériques (image, son, vidéo... ).</p>
                         
                          <h3>Prérequis</h3>
                          <p>Enseignements d’adaptation de parcours.</p>
                          
                          <h3>Contenus</h3>
                          <p>Mathématiques pour le signal (15h) :</p>
                          <ul>
                            <li>Trigonométrie, exponentielle, logarithme.</li>
                            <li>Suites et séries, introduction à la décomposition en série de Fourier, notion de spectre.</li>
                          </ul>
                          <p>Introduction au signal (30h) :</p>
                          <ul>
                            <li>Introduction à la théorie de l’information (signal, classification des signaux, notion d’information, entropie,
                          contenu informatif, notion de codage).</li>
                            <li>Caractéristiques de la vision et de l'audition humaine.</li>
                            <li>Études de sources sonores et visuelles.</li>
                            <li>Les différents modes de représentation de l’information : temporel, fréquentiel.</li>
                            <li>Études de traitements spécifiques et effets spéciaux (égalisation, amplification, modulation,…).</li>
                            <li>Caractéristiques d’un système (Gain, déphasage).</li>
                          </ul>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Définir des cas concrets traités dans le cadre d'autres enseignements et le traiter avec le formalisme
                          mathématique.</p>
                          <p>Les TP utilisant des logiciels de simulation et/ou de traitement d'image et de son doivent être favorisés.</p>
                          <p>Des TP de découverte doivent être privilégiés à des TD dédiés aux techniques de calcul. Il peut être fait référence
                          aux différents transducteurs (antenne, microphone, haut parleur, et CCD…) utilisés dans les systèmes de
                          transmission et audiovisuels.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Série de Fourier, transformation en cosinus discret, intégration, intégrales généralisées.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Logique, trigonométrie, suites, séries. Information, représentation, signal, fréquence. Signal, systèmes, traitement.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
    
          <a data-toggle="modal" href="#m1202" class="element s1 ue2 m1202 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1202</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Algorithmique et programmation</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1202" tabindex="-1" role="dialog" aria-labelledby="m1202" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1202 — Algorithmique et programmation S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">10</td>
                                <td class="td">10</td>
                                <td class="tp">10</td>
                                <td class="total">30</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Initier les étudiants aux bases de l’algorithmique et de la programmation.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable d'analyser des problèmes simples, construire des algorithmes et simuler leur déroulement.</p>
                                                   
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Variables, types scalaires, représentation des données.</p>
                          <p>Programmation structurée, structures de contrôle, trace d’un algorithme, fonctions.</p>
                          <p>Analyse et décomposition de problèmes.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Apprentissage d’un langage de programmation.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Utilisation d'un environnement de développement.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Algorithmique, programmation.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
    
          <a data-toggle="modal" href="#m1203" class="element s1 ue2 m1203 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">3</span></p>
              <p class="id">M1203</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Service sur réseaux</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">15</td>
                  <td class="td">15</td>
                  <td class="tp">20</td>
                  <td class="total">50</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1203" tabindex="-1" role="dialog" aria-labelledby="m1203" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1203 — Services sur réseaux S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">15</td>
                                <td class="td">15</td>
                                <td class="tp">20</td>
                                <td class="total">50</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Comprendre le fonctionnement matériel et logiciel, d'un ordinateur dans son contexte de travail.</p>
                          <p>Obtenir une culture générale sur l’architecture des réseaux en terme de matériel, interconnexion, topologie et
                          support.</p>
                          <p>Avoir des connaissances de base sur Internet : les différents acteurs du réseau, l'organisation.
                          Comprendre le fonctionnement d'IP : adressage et routage statique.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>gérer et mettre en oeuvre une configuration matérielle et logicielle locale ou en réseaux.</li>
                              <li>se servir des systèmes d'exploitation informatique.</li>
                              <li>analyser les protocoles réseaux.</li>
                              <li>comprendre les protocoles et normes télécommunication.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Système d'exploitation et architecture informatique :</p>
                          <ul>
                            <li>Présentation des concepts fondamentaux d'un système d’exploitation multi-utilisateurs : notions de systèmes de
                          fichiers, gestion des taches, notion de processus, les interfaces de commande : graphiques et textuelles.</li>
                            <li>Présentation de l'architecture matérielle d'un système informatique: unités centrales, processeur, mémoire,
                          entrées/sorties, bus, périphériques.</li>
                          </ul>
                          <p>Architectures réseaux :</p>
                          <ul>
                            <li>Présentation d’Internet, des réseaux longues distances et des réseaux cellulaires.</li>
                            <li>Matériels, topologie, supports de transmissions, interconnexions</li>
                            <li>Principes de la commutation de messages, de circuits, de paquets, de cellule</li>
                            <li>Modèle OSI, modèle Internet.</li>
                            <li>Temps de parcours d'architectures : débits, vitesses de propagation, délais.</li>
                          </ul>
                          <p>Protocoles IP :</p>
                          <ul>
                            <li>Adressage IP : réseaux et sous-réseaux</li>
                            <li>Routage statique, routage par défaut</li>
                            <li>ICMP, ARP</li>
                          </ul>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Volume horaire recommandé pour la partie système d'exploitation et architecture informatique : 15 heures</p>
                          <p>TP sur l'installation d'OS : partitionnement, création de comptes, politique de sécurité, installation de logiciels.</p>
                          <p>TP sur la configuration réseau d'OS : configuration IP, commandes « ping », « traceroute », « route », « netstat ».</p>
                          <p>TP sur la configuration de partages de ressources : sous Windows, Linux et en milieu hétérogène Samba.</p>
                          <p>TP d'analyse de trames : en tête IP, modèle en couche.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Atelier d'installation Linux.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Systèmes d'exploitation, processeurs.</p>
                          <p>Réseau local, réseau Internet, matériel, topologie, interconnexion, débit, IP, adresse.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
    
          <a data-toggle="modal" href="#m1204" class="element s1 ue2 m1204 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1204</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Infographie</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">10</td>
                  <td class="tp">20</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1204" tabindex="-1" role="dialog" aria-labelledby="m1204" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1204 — Infographie S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm"></td>
                                <td class="td">10</td>
                                <td class="tp">20</td>
                                <td class="total">30</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Comprendre les aspects techniques relatifs à la production d’images.</p>
                          <p>Être capable de faire des choix techniques et d’intervenir sur les points graphiques d’un projet multimédia.</p>
                          <p>Acquérir une certaine aisance autant dans la manipulation des outils que dans l'exploitation de leurs possibilités
                          au niveau expressif et graphique.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable d'utiliser des logiciels de création d'images, fixes ou animées, vectorielle et bitmap, 2D et 3D.</p>
                                                   
                          <h3>Prérequis</h3>
                          <p>Savoir utiliser un système informatique.</p>
                          
                          <h3>Contenus</h3>
                          <p>Les techniques de production d’images : différents types pour différentes finalités, compréhension des différentes
                          chaînes graphiques.</p>
                          <p>Bases de l’image de type bitmap : retouche, réalisation…</p>
                          <p>Bases de l’image de type vectoriel.</p>
                          <p>Notions techniques : type, taille et résolution, compression et qualité.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Travail sur logiciels de création graphique (bitmap et vectoriel).</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>L’autonomie acquise doit permettre d’appréhender différents logiciels utilisant les concepts d’image bitmap ou
                          vectorielle.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Création graphique, traitement d’image, bitmap et vectoriel, pixel, résolution.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
    
          <a data-toggle="modal" href="#m1205" class="element s1 ue2 m1205 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1205</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Intégration web</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">5</td>
                  <td class="tp">20</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1205" tabindex="-1" role="dialog" aria-labelledby="m1205" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1205 — Intégration web S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">5</td>
                                <td class="td">5</td>
                                <td class="tp">20</td>
                                <td class="total">30</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Connaître les notions de bases de l'intégration Web.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de maîtriser les aspects techniques de la réalisation de documents pour Internet.</p>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Maîtriser la syntaxe HTML et la sémantique des balises.</p>
                          <p>Être capable de créer et utiliser des feuilles de style.</p>
                          <p>Intégrer des éléments multimédia.</p>
                          <p>Savoir organiser les éléments pour réaliser des mises en page simples.</p>
                          <p>Connaître les standards (validation W3C, normes d'accessibilités) et savoir les appliquer.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Acquisition des concepts et pratique sur machine.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Utilisation d’un logiciel d’édition de page web possible.</p>
                          <p>Mettre en ligne un site web sur un serveur distant.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Intégration web, HTML, CSS, sémantique, accessibilités.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
    
          <a data-toggle="modal" href="#m1206" class="element s1 ue2 m1206 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M1206</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Production audiovisuelle</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">5</td>
                  <td class="tp">20</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1206" tabindex="-1" role="dialog" aria-labelledby="m1206" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1206 — Production audiovisuelle S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm">5</td>
                                <td class="td">5</td>
                                <td class="tp">20</td>
                                <td class="total">30</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Connaître et comprendre les concepts et technologies de la production audiovisuelle, en production et post-production.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>régler le matériel en vue de réaliser une prise de vue répondant aux critères de qualité.</li>
                              <li>préparer un projet photo et/ou vidéo en vue d'y importer et insérer une série de séquences épreuves (rushes).</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>Critères de qualité d'une image photo et vidéo (approche technique, son, éclairage, netteté, exposition,
                          colorimétrie).</p>
                          <p>Mise en oeuvre des outils de la prise de vues et de la prise de son numériques, éclairages.</p>
                          <p>Paramètres du projet vidéo et/ou photo – Importation des médias – Conformation et insertion – Raccords –
                          Effets spéciaux – Paramètres d'export en fonction de la cible.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Utilisation de matériel de prise de vues, de prise de son et éclairage dans la réalisation d’un projet photo ou
                          vidéo.</p>
                          <p>Montage à partir de rushes existants, raconter une histoire.</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>Création de scénario, réalisation.</p>
                          
                          <h3>Mots-clés</h3>
                          <p>Production audiovisuelle, post-production, prise de vue, montage.</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
    
          <a data-toggle="modal" href="#m1207" class="element s1 ue2 m1207 harm">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue"></span></p>
              <p class="id">M1207</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Adaptation de parcours</h2>
              <h3 class="cat">Harmonisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td"></td>
                  <td class="tp">15</td>
                  <td class="total">15</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m1207" tabindex="-1" role="dialog" aria-labelledby="m1207" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                          <h4 class="modal-title">M1207 — Adaptation de parcours S1</h4>
                      </div>
                      <div class="modal-body">
                          <table class="table table-striped table-bordered">
                            <thead>
                              <tr>
                                <th>CM</th>
                                <th>TD</th>
                                <th>TP</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              <tr>
                                <td class="cm"></td>
                                <td class="td"></td>
                                <td class="tp">15</td>
                                <td class="total">15</td>
                              </tr>
                            </tbody>
                          </table>
                          <h3>Objectifs du module</h3>
                          <p>Apporter une réponse personnalisée aux besoins d'adaptation des étudiants concernant toutes les matières
                          afférentes à la culture scientifique de l'UE2.</p>
                          <p>Fournir aux étudiants les outils mathématiques de base.</p>
                          
                          <h3>Compétences visées</h3>
                          <p>Être capable de :</p>
                          <ul>
                            <li>faire preuve d'autonomie dans les apprentissages des UE12, UE22, UE32 et UE42.</li>
                              <li>maîtriser des techniques de calcul de base.</li>
                              <li>connaître des fonctions de référence.</li>
                              <li>connaître des outils de base de l’analyse réelle.</li>
                              <li>connaître les éléments de logique de base.</li>
                          </ul>
                         
                          <h3>Prérequis</h3>
                          <p>—</p>
                          
                          <h3>Contenus</h3>
                          <p>En fonction des besoins personnalisés des étudiants l'équipe pédagogique pourra proposer :</p>
                          <ul>
                            <li>de la remédiation,</li>
                            <li>un travail complémentaire.</li>
                          </ul>
                          <p>Les besoins seront identifiés par l'équipe pédagogique au fil des enseignements et amendés si nécessaire par la
                          suite.</p>
                          
                          <h3>Modalités de mise en œuvre</h3>
                          <p>Préconisation : 15h TP en travail thématique (disciplines de l'UE2).</p>
                          
                          <h3>Prolongements possibles</h3>
                          <p>—</p>
                          
                          <h3>Mots-clés</h3>
                          <p>—</p>
                          
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                    </div>
                  </div><!-- /.modal-content -->
              </div><!-- /.modal-dialog -->
          </div>
                
          <a data-toggle="modal" href="#m2101" class="element s2 ue1 m2101 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">1</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2101</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Anglais</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
                    <div class="modal fade" id="m2101" tabindex="-1" role="dialog" aria-labelledby="m2101" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2101 — Anglais S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Développer l’aisance de l’expression orale tant spontanée que continue, accroître l’autonomie dans
                                        l’apprentissage par des pratiques spécifiques, favoriser la connaissance des médias de pays anglophones.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>débattre, argumenter sur des thèmes plus spécifiques au domaine.</li>
                                        <li>rédiger une note de synthèse et de la présenter devant un public.</li>
                                        <li>comprendre et analyser le fonctionnement des médias dont la presse.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1101</p>

                                    <h3>Contenus</h3>
                                    <p>Élaboration d’un document de synthèse, technique de la présentation orale.</p>
                                    <p>Anglais économique : l’univers de l’entreprise.</p>
                                    <p>Anglais technique : les TIC, les réseaux, les systèmes informatiques, le multimédia</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Pour amener l’étudiant à être acteur de son apprentissage : passage régulier en centre de ressources de langues,
                                        introduction d’outils favorisant l’autonomie tels le Portfolio Européen des Langues, recours aux TICE pour l’autoapprentissage.</p>
                                    <p>Rédaction de dossier de presse ou autre, résumés, recherches sur les entreprises (profil, activité, chiffres),
                                        simulation de situations de réunion avec enregistrements vidéo.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Rédaction d’un rapport issu de recherches personnelles.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Débat, rapport, presse, actualité en ligne.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
          
          <a data-toggle="modal" href="#m2102" class="element s2 ue1 m2102 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M2102</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Langue vivante 2</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">20</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2102" tabindex="-1" role="dialog" aria-labelledby="m2102" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2102 — Langue vivante 2 S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">20</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>En se basant sur les acquis du module M1102 développer l’aisance dans les compétences orales et initier à la
                                    langue professionnelle.</p>
                                    <p>S’approprier les techniques de présentation tant orales qu’écrites.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>argumenter, de débattre sur des sujets généraux.</li>
                                        <li>comprendre et analyser des textes plus spécifiques au domaine (informatique, réseaux, Internet, multimédia).</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1102</p>

                                    <h3>Contenus</h3>
                                    <p>La culture de l’entreprise du pays de la langue cible au travers de témoignages, d’interviews, de documents
                                    écrits ; recherches dans le domaine de la culture et de la civilisation du pays concerné.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Études comparatives de statistiques, entraînement à la présentation, recherches des nouveautés dans les TIC
                                    pour les pays concernés, commentaires de faits de société.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Présentation d’une entreprise (document écrit, diaporama…), simulation de débats, rédaction d’une note de
                                    synthèse, voire d’un rapport.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Débat, rapport, presse, actualité en ligne.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
          
          <a data-toggle="modal" href="#m2103" class="element s2 ue1 m2103 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2103</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Théories de l'information et de la communication</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">15</td>
                  <td class="td">15</td>
                  <td class="tp">10</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2103" tabindex="-1" role="dialog" aria-labelledby="m2103" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2103 — Théories de l'information et de la communication S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">15</td>
                                            <td class="td">15</td>
                                            <td class="tp">10</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Compréhension des approches et moyens de la communication des organisations.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de reconnaître les stratégies de communication des organisations, en repérer les enjeux et acteurs,
                                    comprendre et concevoir un plan de communication.</p>
                                    
                                    <h3>Prérequis</h3>
                                    <p>M1103.</p>

                                    <h3>Contenus</h3>
                                    <p>Étude de la communication des organisations, dont la communication d’entreprise. Étude des stratégies, acteurs,
                                    enjeux et moyens de la communication ; communication d’entreprise et d’influence, communication et stratégie
                                    médias ; études de cas.</p>
                                    <p>Histoire et actualité de la publicité ; approches psychologiques, linguistiques, sémiologiques, rhétoriques,
                                    pragmatiques de la publicité ; Analyse de publicités : affiches, spots radio, spots télévisuels ; approche des
                                    campagnes de communication globale (360°, transmédia, plurimédia).</p>
                                    <p>Innovations et communication des organisations : comment l'introduction des TIC induit-elle ou accompagne-t-elle
                                    des modifications organisationnelles ?</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Étude de cas de communication d'entreprises (dossiers écrits, exposés oraux) ; analyses de sites Internet
                                    d'organisations ; analyses de publicités (radio, audiovisuelles, multimédia) ; enquêtes.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Prolongements théoriques autour de l'espace public et de la propagande : M3103.</p>
                                    <p>Prolongements pratiques autour de la communication professionnelle M3106 ; autour de l'écriture web M2105 et
                                    de la gestion de communautés et de la communication virale M3105 ; autour de la mercatique en ligne ; autour
                                    d'atelier de réalisation de supports de communication institutionnelle ou de publicités en infographie et en
                                    production audiovisuelle, de sites d'organisations en intégration internet, éventuellement de campagnes
                                    plurimédia.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Communication des organisations, stratégies, acteurs et enjeux de la communication des organisations,
                                    communication interne et externe ; publicité ; innovations et communication des organisations.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m2104" class="element s2 ue1 m2104 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M2104</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Esthétique et expression artistique</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">25</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2104" tabindex="-1" role="dialog" aria-labelledby="m2104" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2104 — Esthétique et expression artistique S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">25</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Savoir concevoir et décliner une identité visuelle.</p>
                                    <p>Définir une identité sonore sur différents supports de communication.</p>
                                    <p>Connaître les spécificités des médias porteurs de l’identité visuelle ou sonore.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>mettre en oeuvre les fondamentaux du langage plastique et du langage filmique.</li>
                                        <li>choisir les techniques de dessin, d'infographie, d'impression.</li>
                                        <li>faire preuve d'invention et de créativité dans l'utilisation des outils.</li>
                                        <li>utiliser des logiciels de création d'images, fixes ou animées, vectorielle et matricielle (bitmap), 2D et 3D.</li>
                                        <li>appliquer les règles typographiques.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1104.</p>

                                    <h3>Contenus</h3>
                                    <p>Les phases de la création à la diffusion : le brief, la recherche des composantes iconographique et typographique,
                                    la connotation.</p>
                                    <p>Création d’un logo.</p>
                                    <p>Analyse d’identités visuelles et sonores.</p>
                                    <p>Composition d’une charte graphique et d’une charte sonore.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Phase de recherche, conception, création sur papier, phase de finalisation, exécution en infographie ou pratique
                                    traditionnelle, utilisation d’outils de diffusion sonore.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Analyse et conception de créations infographiques, de productions multimédias ou de compositions musicales.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Graphisme, charte graphique, esthétique et ergonomie, identité visuelle, identité sonore, logo.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m2105" class="element s2 ue1 m2105 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M2105</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Écriture pour les médias numériques</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">25</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2105" tabindex="-1" role="dialog" aria-labelledby="m2105" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2105 — Écriture pour les médias numériques S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">25</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Conception d'une ligne éditoriale de publications, de contenus de messages, de supports de communication…
                                    Rédaction d'une charte éditoriale notamment dans le cas d'écriture collaborative</p>
                                    <p>Administration du contenu d'un site web</p>
                                    <p>Mise à jour des données d'activité (tableaux de bord, statistiques, ...) et réalisation du bilan des actions de
                                    communication</p>
                                    <p>Optimisation d'un site pour le référencement</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>Structurer l'information (arborescence, contenus, rubriques, liens...),</li>
                                        <li>Respecter les règles de rédaction pour le web,</li>
                                        <li>Diffuser et communiquer l'information selon les règles en vigueur.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1105</p>

                                    <h3>Contenus</h3>
                                    <p>Écrire pour l'internet ; structurer l'information ; savoir titrer ; savoir hiérarchiser l'information ; travailler les noms de
                                    domaines et les balises ; faire le choix le plus approprié du média (texte, photos, vidéos, infographies
                                    interactives) ; les choix d'illustration ; les règles de lisibilité de l'écriture en ligne ; l'hypertexte et son utilisation ;
                                    approcher des types d'écritures différents : informer/promouvoir ; rechercher ou produire de l'information pour un
                                    site (institutionnel/marchand/bloc-notes/compte de micro bloc-notes) ; organiser l'activité des rédacteurs : éditer
                                    une charte éditoriale ; suivre l'activité sur un site/un blog (tableaux de bord, statistiques) ; écrire pour un utilisateur
                                    humain/pour un moteur de recherche ; optimiser le référencement d'un site ; écrire en direct (le micro bloc-notes
                                    en direct d'un événement).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Analyse de sites internet ; atelier de conception éditoriale sur une page internet ; adapter un document écrit sous
                                    forme web ; rédiger une charte éditoriale pour un bloc-notes collectif ; tenir un bloc-notes notamment sur un
                                    événement au sein du département.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>De nombreux prolongements sont indiqués dans l'application des connaissances en production de médias
                                    numériques ou en intégration web (M2205) ; un prolongement théorique direct est trouvé dans la gestion des
                                    communautés en M3105.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Rédaction web ; Hiérarchisation de l'information ; référencement ; charte éditoriale ; bloc-notes ; micro blocnotes.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m2106" class="element s2 ue1 m2106 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2106</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Communication, expression écrite et orale</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2106" tabindex="-1" role="dialog" aria-labelledby="m2106" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2106 — Expression, communication écrite et orale S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Structurer une réflexion, développer l’esprit critique et la culture générale.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>se documenter, collecter et analyser des informations</li>
                                        <li>connaître et analyser les médias, grand public et spécialisés.</li>
                                        <li>connaître et savoir utiliser les techniques d’argumentation et de persuasion.</li>
                                        <li>organiser et structurer ses idées.</li>
                                        <li>enrichir sa culture générale.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>Enseignements d’adaptation de parcours et M1106, bureautique.</p>

                                    <h3>Contenus</h3>
                                    <p>Approfondissement des techniques de recherche documentaire.</p>
                                    <p>Rédaction et mise en forme de documents : normes de présentation, normes typographiques, fiches
                                    bibliographique et sitographique.</p>
                                    <p>Techniques du compte rendu, du résumé, de la synthèse.</p>
                                    <p>Écritures journalistiques.</p>
                                    <p>Sémiologie de l’image.</p>
                                    <p>Argumentation écrite, orale, par l’image.</p>
                                    <p>Renforcement des compétences linguistiques.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Analyse des médias (presse, sites web), études de cas, participation à des activités culturelles et productions
                                    culturelles, exposés, débats, rédaction de CR, résumés, synthèses, revues de presse, ateliers d’écriture…).</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Pour la sémiologie de l'image, il conviendrait de faire des ponts avec le M2103.</p>
                                    <p>L'analyse des écritures journalistiques et le travail sur l'expression dans le cadre de comptes rendus, notes de
                                    synthèse, résumés peuvent trouver des débouchés dans l'écriture pour les médias numériques (M2105).</p>

                                    <h3>Mots-clés</h3>
                                    <p>Presse, médias, revue de presse, argumenter, synthétiser, TIC, culture.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m2107" class="element s2 ue1 m2107 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2107</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Conduite de projet</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2107" tabindex="-1" role="dialog" aria-labelledby="m2107" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2107 — Gestion de projet S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">15</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Connaître les dimensions temporelles, financières, qualitatives et communicationnelles de la gestion de projet.</p>
                                    <p>Permettre l’appropriation pratique des enseignements théoriques par leur application différenciée aux projets
                                    tutorés ; développer les compétences nécessaires à l’évaluation autonome de la valeur communicationnelle des
                                    produits de projet ; apprendre à maîtriser les techniques de communication mises en oeuvre dans la conduite de
                                    projet ; apprendre à développer une stratégie autonome.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>respecter les normes qualité</li>
                                        <li>appliquer les techniques commerciales, notamment pour les processus d'appels d'offre.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1103, M1106, M1107, M1109.</p>

                                    <h3>Contenus</h3>
                                    <p>Gestion des délais : déterminer les délais des activités, faisabilité, modes de contrôle du temps, ajustements…</p>
                                    <p>Gestion des coûts : connaissance des coûts (postes de charges), analyse des prix pratiqués, tarification (forfait,
                                    temps passé…), chiffrage des aléas.</p>
                                    <p>Gestion de la qualité : normalisation, outils de la qualité, mesure, processus d’évaluation, satisfaction client.</p>
                                    <p>Gestion de la documentation du projet : conventions de présentation d’échange, de mise à jour, uniformisation
                                    des présentations.</p>
                                    <p>Études de cas : analyse des besoins (usagers/commanditaires) ; analyse de la situation de communication ;
                                    stratégies de communication ; choix des supports de communication ; Rédaction d’un cahier des charges
                                    fonctionnelles.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Création d’espace d’échange de documents numériques...</p>
                                    <p>Conception d'un projet de création d'événement ou d'une campagne de communication tous supports.</p>
                                    <p>Les heures TP doivent permettre la découverte, l'apprentissage et l'utilisation des logiciels dédiés.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Le module PPP, l'ensemble des autres modules dans lesquels des projets peuvent être mis en place.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Délais, contrôle du temps, coûts, tarification, normes, qualité.</p>
                                    <p>Analyses des besoins, supports de communication, cahier des charges fonctionnelles, négociation.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m2108" class="element s2 ue1 m2108 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M2108</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">PPP</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">20</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2108" tabindex="-1" role="dialog" aria-labelledby="m2108" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2108 — PPP S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">20</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Le module PPP du S2 doit permettre :</p>
                                    <ul>
                                      <li>à l'étudiant de mieux se connaître pour bien s’orienter dans ses études et dans sa vie professionnelle. Il s’agit
                                    dans ce module de faire en sorte que l’étudiant énonce peu à peu ses goûts, ses souhaits, ses désirs en termes
                                    de projet de vie professionnelle et les confronte à ce qu’il a appris dans le module « Découverte des métiers et
                                    des environnements professionnels et initiation à la démarche de projet ». Il s’agit pour lui de pouvoir ensuite
                                    argumenter sur ses choix quant à son parcours au sein du DUT (Modules complémentaires, options) et post-DUT</li>
                                      <li>à l'équipe d'accompagner l’étudiant dans la détermination du secteur d’activité ou de l’environnement
                                    professionnel dans lesquels il souhaite effectuer son stage ; l’aider à élaborer des outils pertinents et efficients
                                    concernant sa recherche de stage ; lui enseigner une méthodologie de techniques de recherche de stage et
                                    d’emploi</li>
                                    </ul>
                                    

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>faire preuve de réflexivité, de questionnement, d'analyse, d'un esprit de synthèse, de qualités rédactionnelles.</li>
                                        <li>utiliser le système de veille informationnelle commencé au semestre 1, d'en apprécier les qualités et les limites,
                                        et de procéder de façon itérative à sa correction.</li>
                                        <li>mettre en forme de l’information recueillie et analysée.</li>
                                        <li>mettre en oeuvre des plans d’action.</li>
                                        <li>s'auto-former à de nouveaux outils (CV interactifs, portfolios numériques,...).</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1103 ; M1106 ; M1107 ; M1109</p>

                                    <h3>Contenus</h3>
                                    <p>On pourra par exemple faire réfléchir l'étudiant sur ses intérêts professionnels, valeurs, motivations, traits de
                                    personnalité, expériences professionnelles :</p>
                                    <ul>
                                      <li>Démarches et outils des techniques de recherche d’emploi (CV adapté à la cible ; lettre de motivation ; outils de
                                    prospection et de suivi des contacts entreprises ; usage du téléphone et du courriel à des fins professionnelles) ;</li>
                                        <li>Simulations filmées des entretiens, débriefing des enregistrements ;</li>
                                        <li>Analyse d’offres d’emploi…</li>
                                        <li>réputation numérique (e-reputation) et présence sur les réseaux sociaux.</li>
                                    </ul>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Travailler en lien avec le module PPP « Découverte des métiers et des environnements professionnels et initiation
                                    à la démarche de projet » et partir de ce que l’étudiant a appris dans ce cadre pour aller vers l’énonciation de ses
                                    souhaits.</p>
                                    <p>Les TD et TP sont privilégiés pour des travaux de groupes (démarche de recherche d’emploi, etc.). Le travail en
                                    autonomie et individualisé sera essentiel pour l’identification des intérêts professionnels, valeurs, motivation, etc.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Possibilité d’associer des partenaires extérieurs : employeurs, recruteurs, étudiants diplômés…</p>

                                    <h3>Mots-clés</h3>
                                    <p>Réflexivité, CV, lettres de motivation ; entretien de recrutement.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m2109" class="element s2 ue1 m2109 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2109</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Environnement juridique, éco. et merca. des orga.</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">10</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2109" tabindex="-1" role="dialog" aria-labelledby="m2109" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2109 — Environnement juridique, économique et mercatique des organisations S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">10</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>L’objectif de ce cours est de permettre à l’étudiant de développer les connaissances acquises au semestre 1 afin
                                    de pouvoir apporter aux partenaires de l'organisation des réponses appropriées à l'environnement d'une
                                    organisation</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>exploiter de la documentation juridique.</li>
                                        <li>résoudre une situation juridique simple.</li>
                                        <li>appréhender les enjeux de la création d'entreprise et de la prise de décision dans les organisations.</li>
                                        <li>utiliser les techniques d’enquêtes et de comprendre leur influence sur la décision mercatique.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1109</p>

                                    <h3>Contenus</h3>
                                    <p>La formation et la validité des contrats (analyse ou exploitation d’un contrat).</p>
                                    <p>La méthodologie juridique (analyse d’une décision de justice, étude d’un cas juridique).</p>
                                    <p>L'entrepreneuriat : les formalités, le projet, l’idée, les défaillances d’entreprises, mais aussi décisions, pouvoir,
                                    système d’information, évolution des théories des organisations.</p>
                                    <p>Les techniques d'enquêtes, les études documentaires, les études qualitatives, les études quantitatives,
                                    l'intelligence économique et la veille stratégique.</p>
                                    <p>L’analyse du marché, le système d’information, les comportements d’achat des consommateurs, l’environnement,
                                    la segmentation, l’offre.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>A partir d’une étude de cas, analyser la validité d’un contrat ou proposer des solutions juridiques à un problème
                                    réel (création d'entreprise, litige,...).</p>
                                    <p>Réaliser une enquête à l'aide d'un logiciel spécialisé (par exemple pour le lancement d'un projet tutoré ou en
                                    PPP).</p>
                                    <p>Préconisations :</p>
                                    <ul>
                                      <li>droit : 10 heures TD ;</li>
                                      <li>entrepreneuriat : 10 heures CM ;</li>
                                      <li>mercatique : 5 heures TD, 10 heures TP (à réserver pour les enquêtes).</li>
                                    </ul>

                                    <h3>Prolongements possibles</h3>
                                    <p>Prévoir une intervention extérieure sur le thème de l'entrepreneuriat.</p>
                                    <p>Prévoir une intervention sur l'intelligence économique.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Contrat, consentement, annulation, preuve…</p>
                                    <p>Création d’entreprise, communication d’entreprise.</p>
                                    <p>Enquêtes consommateurs, études qualitatives, études quantitatives.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m2208" class="element s2 ue1 m2110 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M2110</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Projet tutoré</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          
                                    
          <a data-toggle="modal" href="#m2201" class="element s2 ue2 m2201 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2201</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Culture scientifique et traitement de l'info.</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">15</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">45</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2201" tabindex="-1" role="dialog" aria-labelledby="m2201" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2201 — Culture scientifique et traitement de l'information S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">15</td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">45</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Fournir aux étudiants les bases mathématiques de l'informatique. Connaître le vocabulaire de la théorie des
                                    ensembles, d'éléments de logique et d'arithmétique.</p>
                                    <p>Approfondir les fonctions principales de systèmes audio-vidéo et de transmission. Comprendre les solutions
                                    technologiques de différents systèmes audiovisuels.</p>
                                    <p>Appréhender le traitement numérique de l’information en vue de la traiter, stocker, diffuser. Connaître les
                                    différentes étapes nécessaires à la numérisation et savoir justifier les paramètres de numérisation des systèmes
                                    d’acquisition des signaux. Connaître les différents standards de signaux numériques audio-vidéo. Connaître les
                                    différents supports et standards de stockage et de diffusion (transmission).</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de comprendre les principes de l'acquisition, du traitement, du stockage et de la transmission
                                    d'informations numériques (image, son, vidéo... ).</p>

                                    <h3>Prérequis</h3>
                                    <p>Enseignements d’adaptation de parcours, M1201.</p>

                                    <h3>Contenus</h3>
                                    <p>Mathématiques pour l'informatique (15h) :</p>
                                    <ul>
                                      <li>Vocabulaire de la théorie des ensembles.</li>
                                        <li>Prédicats, calcul des propositions, raisonnement.</li>
                                        <li>Arithmétique.</li>
                                    </ul>
                                    <p>Numérisation et transmission du signal (30h) :</p>
                                    <ul>
                                        <li>Numérisation (échantillonnage, quantification, codage, multiplexage et débit).</li>
                                        <li>Transmission (émetteur, récepteur), support de transmission (filaire, optique, radio) et bande passante.</li>
                                        <li>Notion de cryptographie : (authentification, intégrité, non répudiation, confidentialité, chiffrement/déchiffrement,
                                    hachage, algorithmes symétriques/asymétriques, signature, PKI).</li>
                                        <li>Stockage, supports de stockage (optique, magnétique), normes et standards.</li>
                                        <li>Signaux audio et signaux de parole numériques et leurs standards.</li>
                                        <li>Signaux vidéo numériques et leurs standards.</li>
                                    </ul>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Définir des cas concrets traités dans le cadre d'autres enseignements et le traiter avec le formalisme
                                    mathématique.</p>
                                    <p>Des TP de découverte doivent être privilégiés à des TD dédiés aux techniques de calcul. Il peut être fait référence
                                    aux différentes techniques de transmission actuelles.</p>
                                    <p>L'application des notions de cryptographie sera abordée dans le module de Services sur Réseaux M3204.
                                    Étudier la structure de fichiers numériques audio.</p>
                                    <p>Mise en pratique ou simulation de l'acquisition, de la numérisation et du traitement du son (compresseur,
                                    égaliseur, correcteur de phase, etc.).</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Nombres complexes.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Ensemble, logique, arithmétique.</p>
                                    <p>Systèmes, transmission, stockage.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m2202" class="element s2 ue2 m2202 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2202</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Développement</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">20</td>
                  <td class="total">45</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2202" tabindex="-1" role="dialog" aria-labelledby="m2202" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2202 — Algorithmique et développement web S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">20</td>
                                            <td class="total">45</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Approfondir les bases de l'algorithmique et de la programmation,</p>
                                    <p>Découvrir la programmation du coté serveur, la génération de pages web dynamique,</p>
                                    <p>Faire les liens avec les notions vues en intégration web.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de générer un contenu web structuré à partir de bases de données.</p>

                                    <h3>Prérequis</h3>
                                    <p>Intégration web M2206 et Bases de données M2203 pour la partie web dynamique</p>

                                    <h3>Contenus</h3>
                                    <p>Définition et manipulation de structures de données usuelles,</p>
                                    <p>Fonctions, procédures, paramètres,</p>
                                    <p>Algorithmes (tris, recherches) et utilisation de bibliothèques de fonctions standards,</p>
                                    <p>Diffusion de l’information (création de pages web dynamiques),</p>
                                    <p>Échange de données entre clients et serveurs web,</p>
                                    <p>Accès à une base de données via un serveur web.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Implantation des algorithmes étudiés,</p>
                                    <p>Apprentissage d'un langage de programmation côté serveur.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Notion de complexité ; récursivité.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Algorithmique, structures de données, web dynamique, client-serveur.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m2203" class="element s2 ue2 m2203 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2203</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Base de données</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2203" tabindex="-1" role="dialog" aria-labelledby="m2203" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2203 — Bases de données S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">15</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Analyser les besoins et modéliser les données d’un système d’information.</p>
                                    <p>Mettre en oeuvre des bases de données en utilisant les SGDB du domaine.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de modéliser, mettre en place et utiliser une base de données.</p>

                                    <h3>Prérequis</h3>
                                    <p>—</p>

                                    <h3>Contenus</h3>
                                    <p>Analyse et modélisation des données : modèle relationnel, modèle relations/entités.</p>
                                    <p>Algèbre relationnelle.</p>
                                    <p>Langage de définition et de manipulation de données.</p>
                                    <p>Intégrité des données, sauvegarde et restauration des données.</p>
                                    <p>Importation de données (fichiers CSV, XML, etc.).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Travail avec un système de gestion de bases de données (SGBD) du domaine.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Administration de bases de données. Utilisation de logiciel de modélisation.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Bases de données, SQL, systèmes d'information, modélisation.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m2204" class="element s2 ue2 m2204 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2204</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Service sur réseaux</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">5</td>
                  <td class="tp">20</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2204" tabindex="-1" role="dialog" aria-labelledby="m2204" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2204 — Services sur réseaux S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">5</td>
                                            <td class="tp">20</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Partager les ressources selon des droits.</p>
                                    <p>Interconnecter un réseau à des réseaux hétérogènes.</p>
                                    <p>Avoir des notions de sécurité sur les réseaux.</p>
                                    <p>Avoir des notions sur les divers réseaux longue distance, les débits disponibles et les coûts.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>appliquer les règles de sécurité informatique et télécommunication.</li>
                                        <li>appliquer les règles de sécurisation de fichiers informatiques.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1204, Notions de cryptographie (M2201).</p>

                                    <h3>Contenus</h3>
                                    <p>Organisation, administration, gestion, sécurité des réseaux locaux.</p>
                                    <p>Réseaux locaux Ethernet : accès au support, concentrateur (hub), commutateur (switch), VLAN, sécurisation.</p>
                                    <p>Réseaux locaux wifi : infrastructure et poste à poste, les normes, les débits, les contraintes de déploiement, la
                                    sécurisation des communications.</p>
                                    <p>Le contrôle de flux sur Internet : TCP, numéro de port, ouverture et fermeture de connexion.</p>
                                    <p>Le transport minimum UDP et son utilité pour les applications interactives (flux en ligne, VOIP...)</p>
                                    <p>Sécurisation matérielle des réseaux locaux : traçage, audit, filtrage, pare feux, réseaux privés virtuels, zone
                                    démilitarisée.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Mise en oeuvre de commutateurs, configuration de VLAN.</p>
                                    <p>Mise en oeuvre et paramétrage de liaison wifi, points d'accès.</p>
                                    <p>Mise en oeuvre et paramétrage de pare-feu logiciel ou matériel.</p>
                                    <p>Administration réseau local : routeur, NAT, DHCP.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>—</p>

                                    <h3>Mots-clés</h3>
                                    <p>Réseau local, Ethernet, Wifi, TCP, UDP, DHCP, NAT, RPV.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m2205" class="element s2 ue2 m2205 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2205</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Infographie</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">5</td>
                  <td class="tp">20</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2205" tabindex="-1" role="dialog" aria-labelledby="m2205" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2205 — Infographie S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">5</td>
                                            <td class="tp">20</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Être capable de mener à bien un projet infographique en vue d’une intégration web.</p>
                                    <p>Maîtrise des outils d’infographie pour la mise en page de document.</p>
                                    <p>Dépasser l'utilisation mécanique du logiciel et utiliser les acquis en esthétique pour exploiter les outils numériques
                                    de manière créative et pertinente vis à vis des contraintes imposées.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>choisir les techniques de dessin, d'infographie, d'impression.</li>
                                        <li>utiliser des logiciels de création d'images, fixes ou animées, vectorielle et bitmap, 2D et 3D.</li>
                                        <li>utiliser un logiciel de Publication Assistée par Ordinateur (PAO).</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1204 et M1104.</p>

                                    <h3>Contenus</h3>
                                    <p>Approfondissement des concepts graphiques et mise en application avec différents logiciels d'infographie.</p>
                                    <p>Développer la capacité à faire des choix techniques pertinents, et à justifier ses choix.</p>
                                    <p>Tenir compte de contraintes imposées (demande du client, cahier des charges, contraintes techniques de
                                    diffusion...).</p>
                                    <p>Maîtriser le vocabulaire et les aspects techniques spécifiques (Formats et résolution, modes colorimétriques,
                                    découpage...).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Travail sur logiciels graphiques.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Ouvertures vers l’animation, la 3D et l’intégration multimédia.</p>

                                    <h3>Mots-clés</h3>
                                    <p>PAO, chaîne graphique, mise en page, composition, impression, page web.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m2206" class="element s2 ue2 m2206 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2206</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Intégration web</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">10</td>
                  <td class="tp">25</td>
                  <td class="total">45</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2206" tabindex="-1" role="dialog" aria-labelledby="m2206" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2206 — Intégration web S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">10</td>
                                            <td class="tp">25</td>
                                            <td class="total">45</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Maîtriser l'intégration Web et la création de mises en pages avancées pour Internet.</p>
                                    <p>Introduction au modèle objet du document et à la programmation événementielle.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>maîtriser les aspects sémantiques du langage HTML et les feuilles de styles.</li>
                                        <li>créer des effets simples d'animation et enrichir l'interaction de pages web.</li>
                                        <li>tenir compte des contraintes de référencement, d'ergonomie et d'accessibilité.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>Notion d'ergonomie et d'écriture multimédia.</p>

                                    <h3>Contenus</h3>
                                    <p>Maîtriser les balises sémantiques du langage HTML et les possibilités de mise en page offertes par CSS
                                    (positionnement, dimensionnement des éléments).</p>
                                    <p>Créer des effets simples avec les feuilles de styles (effets de transitions, menus déroulants, surbrillance du texte,
                                    effets d'animation).</p>
                                    <p>Concevoir des gabarits respectant les règles de référencement, d'ergonomie et d'accessibilité.</p>
                                    <p>Enrichir l'interaction avec un langage de programmation coté client en utilisant des bibliothèques existantes et en
                                    manipulant le modèle objet des documents.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Travail sur machine. Utilisation éventuelle de plate-forme HTML/CSS.</p>
                                    <p>Possibilité d'utiliser des logiciels d'intégration ou de création de contenus interactifs.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Utilisation simple d'un système de gestion de contenus (CMS) : gestion des gabarits et pages types, modification
                                    de l'habillage ou des thèmes graphiques.</p>

                                    <h3>Mots-clés</h3>
                                    <p>HTML, CSS, mise en page, transitions, référencement, ergonomie, accessibilité.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m2207" class="element s2 ue2 m2207 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M2207</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Production audiovisuelle</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">5</td>
                  <td class="tp">20</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2207" tabindex="-1" role="dialog" aria-labelledby="m2207" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2207 — Production audiovisuelle S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">5</td>
                                            <td class="tp">20</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Initiation aux techniques de découpage. Maîtrise des techniques de prise de vues, d'éclairage, de son.</p>
                                    <p>Initiation aux effets spéciaux.</p>
                                    <p>Maîtrise des techniques de prise de vues (vidéo et, ou photo) + éclairage et son.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de réaliser un projet vidéo et, ou photo court finalisé à partir d'un scénario imposé.</p>

                                    <h3>Prérequis</h3>
                                    <p>M1206.</p>
                                    <p>Maîtrise des outils de prise de vues et la lumière, prise de son et montage.</p>
                                    <p>Connaissance de la grammaire filmique.</p>

                                    <h3>Contenus</h3>
                                    <p>Approfondissement du vocabulaire, de la grammaire filmique,</p>
                                    <p>Découpage technique d’un scénario imposé (type magazine TV, web TV…),</p>
                                    <p>Tournage et montage,</p>
                                    <p>Comparaison des différents films réalisés et critique.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>En équipe, découpage et tournage d'un scénario imposé. Utilisation de la grammaire filmique.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Réalisation.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Travail en équipe, planification.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m2208" class="element s2 ue2 m2208 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">2</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M2208</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Projet tutoré</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m2208" tabindex="-1" role="dialog" aria-labelledby="m2208" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M2110/M2208 — Projet tutoré S2</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">—</td>
                                            <td class="td">—</td>
                                            <td class="tp">—</td>
                                            <td class="total">—</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Développer un projet technique de production multimédia et, ou internet.</p>
                                    <p>Développement des compétences relationnelles et de l’autonomie dans le travail.</p>
                                    <p>Mise en oeuvre des méthodes de conduite de projet.</p>
                                    <p>Conduire en équipe un projet d’envergure professionnelle mettant en oeuvre la transversalité des connaissances
                                    techniques, technologiques et générales de la spécialité.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>animer une réunion, conduire un projet, construire un budget, gérer des ressources, appliquer les
                                        techniques de management, définir une stratégie de communication, travailler en équipe, formaliser un
                                        processus de gestion de projet,</li>
                                        <li>justifier une démarche ainsi que des choix esthétiques et techniques, appliquer le droit de l’information,
                                        de la propriété intellectuelle et du droit à l’image,</li>
                                        <li>s’autoformer à de nouveaux outils, logiciels, technologies, être autonome et faire preuve d’initiative,</li>
                                        <li>exploiter les compétences acquises ou en cours d'acquisition dans les autres modules,</li>
                                        <li>synthétiser l’information et la restituer sous forme écrite et/ou orale,</li>
                                        <li>mettre en oeuvre une démarche d'intelligence économique : veille, enquête de terrain (benchmarking).</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>L'ensemble des modules.</p>

                                    <h3>Contenus</h3>
                                    <p>Le projet doit avoir une envergure réaliste pour mettre en oeuvre l’ensemble des activités, des tâches et des
                                    contraintes de la conduite d’un projet industriel ou de service, à savoir :</p>
                                  <ul>
                                      <li>constitution d’une équipe ; répartition et planification des tâches ; gestion du temps et des délais ;</li>
                                        <li>utilisation d’outils de gestion de projet ;</li>
                                        <li>analyse comparative de diverses solutions techniques et technologiques ;</li>
                                        <li>rédaction documentation, mémoire, cahier des charges ;</li>
                                        <li>présentation orale soutenue par un support multimédia adapté.</li>
                                    </ul>
                                    <p>Il peut porter sur :</p>
                                    <ul>
                                        <li>la conception et développement d’un site web dynamique, d’un projet audiovisuel ou d'un produit
                                    multimédia (application mobile, visite virtuelle, installation numérique, réalité augmentée, jeu vidéo) ;</li>
                                      <li>l'organisation d’un événement ou d’une campagne de communication pluri-média.</li>
                                    </ul>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Il nécessite la constitution d’une équipe projet de 4 à 8 étudiants. L’accompagnement est assuré par l'équipe
                                    pédagogique, éventuellement complétée par un intervenant professionnel. La phase de réalisation n’est pas une
                                    fin en soi à ce stade.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Modules PPP, stage.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Développement web, programmation, production audiovisuelle, infographie, réalisation multimédia,
                                    documentation, TIC, autonomie, initiative, relation client, analyse des besoins, cahier des charges, équipe.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3101" class="element s3 ue1 m3101 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3101</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Anglais</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3101" tabindex="-1" role="dialog" aria-labelledby="m3101" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3101 — Anglais S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Prolonger les acquis de M1101 et M2101 pour permettre d’utiliser de manière plus active l’anglais du domaine
                                    professionnel et technique.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de faire un exposé à l’oral à l'aide d'un logiciel de présentation, ainsi que de présenter un projet sous
                                    forme écrite.</p>
                                    <p>Être capable de justifier une intention, un effet produit, une stratégie.</p>
                                    <p>Être capable de faire des démarches de recherche d’emploi ou de stage dans un pays anglophone et de rédiger
                                    les écrits formels nécessaires (lettre de motivation, de candidature spontanée), et/ou être capable de rédiger un
                                    rapport synthétique de projet tutoré.</p>

                                    <h3>Prérequis</h3>
                                    <p>M2101.</p>

                                    <h3>Contenus</h3>
                                    <p>Étude de médias comme la publicité ; techniques de la publicité : analyse et conception, la publicité comme
                                    sensibilisation à l’interculturel, étude d’un film ou d’extraits (analyse d’images, des techniques utilisées), –
                                    vocabulaire de la technique cinématographique.</p>
                                    <p>Anglais professionnel : les écrits formels – l’entretien d’embauche (avec prise en compte de la problématique
                                    interculturelle).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Rédaction de scénario, réalisation de maquettes vidéo, analyse et conception de spots, affiches, simulation
                                    d’entretiens.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Parallèle entre l’oeuvre cinématographique et l’oeuvre littéraire, traductions techniques, présentation de projet
                                    multimédia en lien avec les autres modules.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Film, cinéma, publicité, CV, lettre de motivation, rapport synthétique.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3102" class="element s3 ue1 m3102 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M3102</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Langue vivante 2</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">20</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3102" tabindex="-1" role="dialog" aria-labelledby="m3102" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3102 — Langue vivante 2 S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">20</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Préparer à un séjour professionnel éventuel dans le ou les pays de la langue cible.</p>
                                    <p>Développer la compétence de l’écrit.</p>
                                    <p>Avoir une connaissance des médias du ou des pays concernés (presse – radio – télévision – publicité – cinéma).
                                    Prendre en compte les stéréotypes.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de faire un exposé à l’oral à l'aide d'un logiciel de présentation, ainsi que de présenter un projet sous
                                    forme écrite.</p>
                                    <p>Être capable d'analyser les mentalités, en appréhendant le contenu implicite de supports divers.</p>
                                    <p>Être capable de rédiger des écrits professionnels simples.</p>
                                    
                                    <h3>Prérequis</h3>
                                    <p>M2102.</p>
                                    <p>Comprendre des documents divers dans la langue cible et savoir s’exprimer à leur propos de manière spontanée.</p>

                                    <h3>Contenus</h3>
                                    <p>Analyse des médias existants – étude d’un film et / ou d’extraits.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Simulation d’une émission d’actualité, recherches sur Internet, lecture comparative de journaux (gros titres,
                                    manchette..), conception et analyse de spots publicitaires, analyse et réalisation d’enquêtes, mise en lumière de
                                    stéréotypes.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Réflexion sur l’usage des langues dans le projet multimédia (site et cédérom) – stage à l’étranger – réalisation
                                    d’un roman-photos. Rédaction du CV et de la lettre de candidature dans la langue cible.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Actualité, film, presse, écrits professionnels, enquêtes.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3103" class="element s3 ue1 m3103 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3103</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Théories de l'information et de la communication</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">15</td>
                  <td class="td">15</td>
                  <td class="tp">10</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3103" tabindex="-1" role="dialog" aria-labelledby="m3103" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3103 — Théories de l'information et de la communication S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">15</td>
                                            <td class="td">15</td>
                                            <td class="tp">10</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Acquisition de connaissances et compétences en matière d’analyse et de critique des médias dans la société
                                    (presse, radio, télévision, Internet).</p>
                                    <p>Connaître les différentes techniques d’analyse des médias.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de choisir et appliquer les différentes techniques d’analyse en fonction des médias et des objectifs
                                    choisis.</p>

                                    <h3>Prérequis</h3>
                                    <p>M1103, M1203, M2106.</p>

                                    <h3>Contenus</h3>
                                    <p>Histoire de la presse et des médias de masse ; les questions du public, de l'opinion, de l'espace public :
                                    Koselleck, Habermas, Negt... ; la psychologie des foules : Le Bon, Freud... ; théories critiques des médias :
                                    Horkheimer, Adorno, Benjamin, Honneth... ; la question des usages : de Certeau... ; la réception et les études
                                    culturelles : Jonas, Hall, Fiske... ; la question des effets : Lasswell, Katz... ; la propagande : Bernays, Tchakhotine,
                                    Klemperer... ; démarches analytiques (linguistiques, sémiologiques, pragmatiques), techniques de décryptage.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Étude des textes fondateurs ; analyse de presse d'opinion ; analyse d'affiches de propagande ; analyse
                                    d'actualités cinématographiques ; analyse de séquences cinématographiques (cinéma de propagande) ; exposés
                                    de culture médiatique ; dissertation...</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Approfondissement éventuel dans le cadre des modules complémentaires en vue d'une poursuite d'études dans
                                    la filière Information/Communication ?</p>

                                    <h3>Mots-clés</h3>
                                    <p>Histoire des médias, usages, théories de la réception, sociologie des médias de masse, espace public, rumeur,
                                    propagande, désinformation.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3104" class="element s3 ue1 m3104 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M3104</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Esthétique et expression artistique</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">25</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3104" tabindex="-1" role="dialog" aria-labelledby="m3104" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3104 — Esthétique et expression artistique S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">25</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Approfondissement et perfectionnement des pratiques graphiques et artistiques.
                                    Apporter des éléments de réflexion sur l’art pour mener les étudiants vers une meilleure utilisation des images et
                                    du son.</p>
                                    <p>Savoir analyser la plastique et la sémantique d’images et d’oeuvres d’art.</p>
                                    <p>Affirmer le sens artistique et la créativité.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>mettre en oeuvre les fondamentaux du langage plastique et du langage filmique.</li>
                                        <li>choisir les techniques de dessin, d'infographie, d'impression.</li>
                                        <li>faire preuve d'invention et de créativité dans l'utilisation des outils.</li>
                                        <li>justifier une démarche ainsi que des choix esthétiques et techniques.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1104 et M2104.</p>

                                    <h3>Contenus</h3>
                                    <p>Approche sémiologique de l’image et du son.</p>
                                    <p>Mise en perspective des arts avec d’autres champs disciplinaires (science, informatique, audiovisuelle…).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>—</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Analyse et conception de créations infographiques et productions multimédias.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Esthétique, sémiologie, composition, analyse d’oeuvres d’art, création numérique.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3105" class="element s3 ue1 m3105 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3105</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Écriture pour les médias numériques</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">10</td>
                  <td class="tp">15</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3105" tabindex="-1" role="dialog" aria-labelledby="m3105" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3105 — Écriture pour les médias numériques S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">10</td>
                                            <td class="tp">15</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Gestion des communautés.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>faire preuve d'invention et de créativité dans l'utilisation des outils.</li>
                                        <li>utiliser les réseaux stratégiques d'information.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M2105 et M2103.</p>

                                    <h3>Contenus</h3>
                                    <p>Les modalités de mise en place d'une stratégie de présence efficace pour une organisation en identifiant les
                                    médias sociaux adaptés : connaissance des différents réseaux sociaux.</p>
                                    <p>Réaliser la promotion de dispositifs et de contenus d'information sur les médias sociaux et le web.</p>
                                    <p>Comprendre comment animer et interagir avec une communauté ; organiser pour ses membres des événements
                                    (concours, jeux...) ; inciter ses membres à créer du contenu.</p>
                                    <p>Savoir identifier les influenceurs autour de thématiques précises. Relayer leurs positions auprès des dirigeants de
                                    l'organisation.</p>
                                    <p>Comprendre les différents indicateurs et outils de mesure et d'analyse pour évaluer l'impact. Optimiser l'usage
                                    des réseaux sociaux.</p>
                                    <p>Identifier les médias sociaux externes (sites, blogs, réseaux sociaux, forums...) qui parlent d'une organisation afin
                                    de participer au dialogue et de le modérer ; gérer la réputation numérique d'une organisation.</p>
                                    <p>Appréhender la complexité de campagnes de mercatique virale.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Études de cas ; ateliers d'utilisation des différents réseaux sociaux ; travaux pratiques sur des statistiques (les lire,
                                    les analyser) ; concevoir des jeux pour les réseaux sociaux.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Mercatique virale ; utilisation de ces techniques dans le cadre des projets ; développement web spécifique aux
                                    jeux sur réseaux sociaux...</p>

                                    <h3>Mots-clés</h3>
                                    <p>Réseaux sociaux ; réputation numérique ; communautés ; gestion de communauté ; modération ; influence ; jeux ;
                                    mercatique virale.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3106" class="element s3 ue1 m3106 com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3106</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Communication, expression écrite et orale</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3106" tabindex="-1" role="dialog" aria-labelledby="m3106" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3106 — Expression, communication écrite et orale S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Communiquer en milieu universitaire et professionnel : formaliser une expérience.</p>
                                    <p>Maîtriser les modalités de la communication en milieu professionnel.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>comprendre, concevoir et rédiger des documents professionnels.</li>
                                        <li>analyser et de comprendre les relations interpersonnelles dans les groupes de travail.</li>
                                        <li>se situer dans les relations interindividuelles.</li>
                                        <li>gérer ses interventions dans un groupe.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M2106.</p>

                                    <h3>Contenus</h3>
                                    <p>Écrits et oraux professionnels :</p>
                                    <p>Méthodologie du rapport de stage et préparation de la soutenance.</p>
                                    <p>Communication interpersonnelle (Préconisation 10 heures de TP) :</p>
                                    <p>Conduite de réunion, négociation, intégration au groupe, gestion des conflits. Travail sur l’écoute, la reformulation
                                    et l’observation. Analyse de situations de communication interpersonnelle ; analyse du non-dit ; analyse et
                                    synthèse des besoins des interlocuteurs ; choix de comportements en fonction des situations de communication ;
                                    travail d’argumentation et de négociation.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Rédaction du rapport de stage (compléments sur les normes de présentation), aide à la préparation de la
                                    soutenance.</p>
                                    <p>Ateliers de mise en situation.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Projets tutorés, stages, PPP.</p>
                                    <p>Actions de communication événementielle (forum, salons…).</p>

                                    <h3>Mots-clés</h3>
                                    <p>Rapports, soutenance, communication interpersonnelle, communications professionnelles, exploration des
                                    situations de communication orale, conduite de réunions, entretiens, argumentation, autonomie.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3107" class="element s3 ue1 m3107 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M3107</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Conduite de projet</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">25</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3107" tabindex="-1" role="dialog" aria-labelledby="m3107" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3107 — Gestion de projet S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">25</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Apprécier les conditions de réussite de la conduite de projet, maîtriser le suivi des étapes de gestion de ces
                                    projets.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>formaliser un processus de gestion de projet.</li>
                                        <li>conduire un projet.</li>
                                        <li>rendre compte d'un projet de sa gestion.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M2107.</p>

                                    <h3>Contenus</h3>
                                    <p>Suivi opérationnel du projet : mesure des écarts prévisions – réalisations, rétroactivité.</p>
                                    <p>Tableaux de bord de pilotage : outils de mesure.</p>
                                    <p>Le cycle de vie du projet : pérennité du projet, veille technologique.</p>
                                    <p>Clôture du projet et valorisation des résultats obtenus : intégration du projet dans l’organisation, communication
                                    sur le projet, formation des utilisateurs, mesure de la valeur ajoutée.</p>
                                    <p>Maintenance : guide de mise à jour, guide des procédures.</p>
                                    <p>Méthodes agiles avancées.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Le module peut être mis en place autour de la gestion de projets spécifiques, ou des projets tutorés.</p>
                                    <p>Les heures TP seront par exemple utilisées pour la mise en place d'un projet grâce aux méthodes agiles.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Présenter l'importance de la gestion de projet pour la soutenance des projets professionnels (type soutenance de
                                    stages par exemple).</p>

                                    <h3>Mots-clés</h3>
                                    <p>Cycle de vie du projet, suivi, maintenance, tableaux de bord, valorisation du projet.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3108" class="element s3 ue1 m3108 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M3108</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">PPP</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">10</td>
                  <td class="tp">10</td>
                  <td class="total">20</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3108" tabindex="-1" role="dialog" aria-labelledby="m3108" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3108 — Projet Personnel et Professionnel S3
                                    préparer son parcours post-DUT</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">10</td>
                                            <td class="tp">10</td>
                                            <td class="total">20</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Il s’agit de permettre à l’étudiant de construire son parcours post-DUT, en analysant les différentes pistes qui
                                    s’offrent à lui afin qu’il choisisse et mette en oeuvre la plus pertinente pour lui. L’étudiant devra acquérir des
                                    connaissances sur les formations complémentaires au DUT et sur les parcours post DUT, sur la formation tout au
                                    long de la vie (VAP, VAE, FTLV). Il devra également savoir déchiffrer une offre d’emploi, une offre de formation,
                                    pour mieux appréhender le marché de l’emploi. Un premier positionnement de l’étudiant entre le secteur d’activité
                                    visé et ses motivations peut se faire.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>concevoir et mettre en oeuvre d’un projet.</li>
                                        <li>faire preuve d'un esprit d’analyse.</li>
                                        <li>faire preuve d'une capacité de mise en forme de l’information.</li>
                                        <li>appliquer les principes déontologiques liés aux débats et aux échanges.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M2103 ; M2106 ; M2107 ; M2109.</p>

                                    <h3>Contenus</h3>
                                    <p>ateliers d’échanges de réflexion sur les diverses possibilités post-DUT (discussion collective des avantages et
                                    des inconvénients de chaque piste) ;</p>
                                    <p>analyse des offres d’emploi ;</p>
                                    <p>analyse des offres de formation pour un secteur donné à partir de l’enquête nationale de parcours des diplômés
                                    par exemple ;</p>
                                    <p>rencontre avec des anciens diplômés, des professionnels ;</p>
                                    <p>réactivation des techniques de recherche d’emploi ;</p>
                                    <p>présentation des possibilités de formation tout au long de la vie (CIF, VAE, …) ;</p>
                                    <p>analyser les compétences acquises lors d’une expérience professionnelle ou personnelle et reprendre le CV
                                    établi lors du module PPP « formalisation du projet : mieux se connaître et préparer son stage ».</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Par exemple, sous forme d’ateliers d’analyse des offres d’emploi, de formation ; en travaillant avec les résultats
                                    des enquêtes nationales sur le devenir des diplômés de DUT…</p>
                                    <p>Les TD et TP seront privilégiés pour des travaux de groupes. Le travail en autonomie et individualisé sera
                                    essentiel pour l’analyse des compétences acquises en situation professionnelle.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Ce module s’inscrit dans la poursuite des modules de S1 et S2. Il peut reprendre des actions déjà mises en
                                    oeuvre auparavant et les compléter par de nouvelles.</p>

                                    <h3>Mots-clés</h3>
                                    <p>VAE, VAP, formation tout au long de la vie, niveau II, Niveau III, code ROME.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3109" class="element s3 ue1 m3109 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3109</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Environnement juridique, éco. et merca. des orga.</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">25</td>
                  <td class="td">15</td>
                  <td class="tp"></td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3109" tabindex="-1" role="dialog" aria-labelledby="m3109" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3109 — Environnement juridique, économique et mercatique des organisations S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">25</td>
                                            <td class="td">15</td>
                                            <td class="tp"></td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Ce module propose d'utiliser les connaissances acquises lors des semestres précédents pour mettre en oeuvre
                                    pratiquement des modalités juridiques et mercatiques de création, de fonctionnement et de lancement d'un
                                    produit ou d'un service informationnel en situation.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>cerner et qualifier les stratégies génériques et spécifiques d'entreprises et de groupes d’entreprises.</li>
                                        <li>identifier les acteurs, les stratégies et les contraintes d'un secteur particulier de l'économie : le marché des
                                        médias.</li>
                                        <li>appliquer le droit de l'information, de la propriété intellectuelle et du droit à l'image et respecter la réglementation
                                        des jeux et des concours.</li>
                                        <li>conduire une démarche cohérente et complète de mercatique en ligne et, ou hors-ligne.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M2109.</p>

                                    <h3>Contenus</h3>
                                    <p>La protection des données personnelles (Loi du 6 janvier 1978, déclaration CNIL).</p>
                                    <p>La propriété industrielle (le droit des brevets, le droit des marques).</p>
                                    <p>La propriété intellectuelle (le droit d’auteur, la protection des logiciels et bases de données, le contrat de création
                                    de site Internet).</p>
                                    <p>La protection de l’information (les principes du droit de la communication, les atteintes à la vie privée et le droit à
                                    l’image).</p>
                                    <p>La réglementation des jeux et concours.</p>
                                    <p>Pour les marchés comme par exemple celui de l’audiovisuel, de la presse écrite, ou du jeu vidéo… : étude des
                                    stratégies génériques (croissance externe, croissance interne, internationalisation, sous-traitance, impartition…)
                                    et les évolutions de ces marchés liées aux nouvelles technologies (par exemple TV par ADSL, radio numérique,
                                    TNT…).</p>
                                    <p>Le financement et les coûts des médias.</p>
                                    <p>Le plan de communication, l’identité de marque, les principales formes de communication de l’entreprise, la
                                    stratégie médias, hors-médias, et les évolutions de la communication grâce aux nouveaux outils et médias.</p>
                                    <p>La mercatique en ligne.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Les étudiants seront mis dans la position d’une organisation prête, d’un point de vue technique et économique, à
                                    lancer un produit de communication et devront être capables de procéder à un audit juridique du support en
                                    question. Il s'agira, à partir de ce cas concret, d'analyser les besoins de l’organisation, de réaliser un audit
                                    juridique, d'établir sa déclaration CNIL, d'analyser sa stratégie générale, sa stratégie mercatique et sa stratégie
                                    en ligne.</p>
                                    <p>Travailler à partir d’exemples concrets (groupes de presse, groupes de communication, etc.).</p>
                                    <p>Préconisations :</p>
                                    <ul>
                                      <li>Droit : 8 heures CM ;</li>
                                      <li>Économie des médias : 8 heures CM et 5 heures TD ;</li>
                                      <li>Mercatique en ligne et applications : 9 heures CM et 10 heures TD.</li>
                                    </ul>

                                    <h3>Prolongements possibles</h3>
                                    <p>Visite d’un grand quotidien.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Droits des personnes fichées, CNIL, brevet, marques, invention, idée, droit moral, droit patrimonial, droit de
                                    reproduction, dépôt légal, diffamation, prescription, responsabilité, respect vie privée.</p>
                                    <p>Économie des médias, stratégie des entreprises, coûts des médias.</p>
                                    <p>Communication commerciale, création, stratégie, positionnement, trans-média, communication 360°.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m3208" class="element s3 ue1 m3110 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M3110</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Projet tutoré</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          
                                              
          <a data-toggle="modal" href="#m3201" class="element s3 ue2 m3201 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3201</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Culture scientifique et traitement de l'info.</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">20</td>
                  <td class="total">45</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3201" tabindex="-1" role="dialog" aria-labelledby="m3201" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3201 — Culture scientifique et traitement de l'information S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">20</td>
                                            <td class="total">45</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Fournir aux étudiants les bases mathématiques du multimédia.</p>
                                    <p>Maîtriser l'utilisation des codecs audio-vidéo.</p>
                                    <p>Connaître les caractéristiques des images fixes et la structure des fichiers informatiques associés, connaître les
                                    techniques de compression et de codage d’images fixes et les principaux traitements d’images incorporés dans
                                    les logiciels.</p>
                                    <p>Connaître le calcul matriciel et les transformations géométriques du plan de l’espace.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de comprendre les principes de l'acquisition, du traitement, du stockage et de la transmission
                                    d'informations numériques (image, son, vidéo... ).</p>

                                    <h3>Prérequis</h3>
                                    <p>M1201, M2201</p>

                                    <h3>Contenus</h3>
                                    <p>Mathématiques pour le multimédia (10h) :</p>
                                    <ul>
                                      <li>Calcul matriciel.</li>
                                        <li>Transformations géométriques du plan et de l’espace.</li>
                                    </ul>
                                    <p>Traitement numérique du signal (35h) :</p>
                                    <ul>
                                        <li>Codecs audio-vidéo-parole, la compression vidéo.</li>
                                        <li>Images « bitmap » et vectorielles et leurs standards de fichiers.</li>
                                        <li>Notion de transparence et de palettes de couleurs.</li>
                                        <li>Images compressées.</li>
                                        <li>Notion de traitement d’image (contraste, accentuation, contours, etc.)</li>
                                    </ul>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Définir des cas concrets traités dans le cadre d'autres enseignements et le traiter avec le formalisme
                                    mathématique.</p>
                                    <p>Il est préconisé d’étudier d’abord la compression JPEG, MJPEG et enfin la compression MPEG (1, 2…). Les
                                    contraintes temps réel sur la compression pourront être mises en évidence au travers du flux en ligne (streaming)
                                    et de la vidéoconférence. Les TD pourront être dédiés à des calculs de taille de fichiers ou de débit.</p>
                                    <p>Aborder la structure des fichiers informatiques des images « bitmap » et vectorielles. Étudier les codages (RLC,
                                    statistique et dictionnaire) au travers d’exemples connus comme tiff, gif, png, zip, jpeg, eps et autres formats de
                                    portage.</p>
                                    <p>Il est préconisé de faire des liens avec les enseignements d'infographie et d'audiovisuel.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Introduction aux fractales.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Calcul matriciel, transformation géométrique.</p>
                                    <p>Codec.</p>
                                    <p>Images bitmap, images vectorielles, images compressées, traitement d’images.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m3202" class="element s3 ue2 m3202 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3202</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Développement web</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">20</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3202" tabindex="-1" role="dialog" aria-labelledby="m3202" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3202 — Développement web S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">20</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Savoir concevoir et développer des applications web pour la diffusion et la gestion de contenu.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de réaliser des sites web dynamiques complets en prenant en compte les contraintes d'ergonomie et
                                    de navigation définies dans un cahier des charges.</p>

                                    <h3>Prérequis</h3>
                                    <p>M1202, M2202</p>

                                    <h3>Contenus</h3>
                                    <p>Systèmes de gestion de contenu, services web, génération de flux (RSS, XML, etc.).</p>
                                    <p>Conception et génération dynamique d’interfaces et de contenu.</p>
                                    <p>Gestion de contenu : accès, mise à jour et administration de bases des données via le web.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Développement de sites web dynamiques de type livres d'or, forum, galerie, catalogue, etc.</p>
                                    <p>Mise en place d’un système de gestion de contenu.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Gestion des sessions, cookies et authentification.</p>
                                    <p>Modélisation des traitements.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Web dynamique, services web, gestion de contenu</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m3203" class="element s3 ue2 m3203 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3203</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Programmation objet</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">20</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3203" tabindex="-1" role="dialog" aria-labelledby="m3203" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3203 — Programmation objet et événementielle S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">20</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Introduire la conception objets et l'appliquer dans le domaine du multimédia.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de concevoir une application multimédia avec une approche objet.</p>

                                    <h3>Prérequis</h3>
                                    <p>M1203, M2203</p>

                                    <h3>Contenus</h3>
                                    <p>Conception et modélisation objets (classes, méthodes, héritage).</p>
                                    <p>Application à la réalisation d’animations et de programmes interactifs.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Étude d’un langage spécifique du domaine.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Travail avec des logiciels d’intégration multimédia du domaine.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Programmation orientée objets, Animations, Programmation événementielle.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m3204" class="element s3 ue2 m3204 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3204</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Service sur réseaux</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">20</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3204" tabindex="-1" role="dialog" aria-labelledby="m3204" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3204 — Services sur réseaux S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">20</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Mettre en place des services Internet.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable d’installer et d’utiliser les services Internet (résolution de noms, courrier électronique, consultation de
                                    pages Web, transfert de fichiers,…) au niveau serveurs et clients.</p>

                                    <h3>Prérequis</h3>
                                    <p>M1204, M2204.</p>

                                    <h3>Contenus</h3>
                                    <p>Service de résolution de noms : DNS.</p>
                                    <p>Service de courrier électronique : SMTP, POP, IMAP, MIME.</p>
                                    <p>Service de pages Web statique et dynamique : HTTP, HTTPS, LAMP.</p>
                                    <p>Service de transfert de fichiers : FTP.</p>
                                    <p>Service de flux en ligne (streaming).</p>
                                    <p>Installation, configuration, gestion et utilisation des services Internet ; configuration de serveurs et de clients.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>TP d’installation, de configuration et d’utilisation des divers services au niveau clients et serveurs.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>—</p>

                                    <h3>Mots-clés</h3>
                                    <p>Internet, services, client, serveur.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m3205" class="element s3 ue2 m3205 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3205</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Infographie</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">20</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3205" tabindex="-1" role="dialog" aria-labelledby="m3205" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3205 — Infographie S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">20</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Appréhender les notions de design en mouvement</p>
                                    <p>Être capable de mettre en oeuvre une production interactive et, ou animée.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable d'utiliser des logiciels de création d'images, fixes ou animées, vectorielle et bitmap, 2D et 3D.</p>

                                    <h3>Prérequis</h3>
                                    <p>M1205, M2205, M1104, M2104.</p>

                                    <h3>Contenus</h3>
                                    <p>Principes de base de l'animation 2D.</p>
                                    <p>Apprentissage de logiciels d'animation.</p>
                                    <p>Initiation aux techniques d'animation (motion design).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Travail sur machine.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Animation 3D, post-production, composition d'images (compositing).</p>

                                    <h3>Mots-clés</h3>
                                    <p>Animation (motion design).</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m3206" class="element s3 ue2 m3206 info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3206</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Intégration multimédia</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">20</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3206" tabindex="-1" role="dialog" aria-labelledby="m3206" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3206 — Intégration multimédia S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">20</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Adapter le contenu et la mise en page d'interfaces en fonction du périphérique d'affichage.</p>
                                    <p>Savoir créer des interfaces riches et dynamiques.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>adapter le contenu et la mise en page de sites web à la taille et à la résolution du périphérique d'affichage.</li>
                                        <li>intégrer des données multimédia et permettre des interactions avec elles.</li>
                                        <li>créer et programmer des animations simples.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>Notions d'ergonomie et d'infographie, M3202 pour la partie programmation.</p>

                                    <h3>Contenus</h3>
                                    <p>Concevoir et développer des sites web dont le contenu et la mise en page s'adaptent aux périphériques utilisés
                                    (écrans d'ordinateur, télévisions, téléphones, tablettes, etc.).</p>
                                    <p>Créer des animations simples : dessiner, animer et transformer des illustrations simples.</p>
                                    <p>Enrichir l'interaction avec des modules dynamiques et des outils d'interaction personnalisés (calendriers,
                                    diaporamas, carrousels, etc.) en utilisant un langage de programmation du coté client.</p>
                                    <p>Assurer la compatibilité d'un site avec différents navigateurs.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Utilisation de plate-formes ou d'environnements de développement dédiés.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Réalisation d’un projet multimédia.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Intégration multimédia multi-support, animations, interactions, adaptabilité.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m3207" class="element s3 ue2 m3207 esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M3207</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Production audiovisuelle</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">5</td>
                  <td class="td">10</td>
                  <td class="tp">20</td>
                  <td class="total">35</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3207" tabindex="-1" role="dialog" aria-labelledby="m3207" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3207 — Production audiovisuelle S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">5</td>
                                            <td class="td">10</td>
                                            <td class="tp">20</td>
                                            <td class="total">35</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Écrire, tourner, monter et diffuser une oeuvre audiovisuelle / photographique originale.</p>
                                    <p>Faire le lien avec les aspects transmédia / multimédia.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de concevoir et réaliser un court-métrage ou une réalisation photo en vue de sa diffusion sur
                                    différents supports.</p>

                                    <h3>Prérequis</h3>
                                    <p>M2206.</p>

                                    <h3>Contenus</h3>
                                    <p>Réalisation / production d’une oeuvre complète photo / vidéo.</p>
                                    <p>Les aspects multimédias pourront être valorisés pour la conception et la diffusion :</p>
                                    <ul>
                                      <li>vidéo interactive (hypervidéo),</li>
                                      <li>mise en ligne pour diffusion sur le Web (flux en ligne, web tv…).</li>
                                    </ul>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Perfectionnement du travail en équipe.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Post-production, stratégie de diffusion.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Travail en équipe, réalisation, diffusion, mise en ligne.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                        
          <a data-toggle="modal" href="#m3208" class="element s3 ue2 m3208 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">3</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">1</span></p>
              <p class="id">M3208</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Projet tutoré</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m3208" tabindex="-1" role="dialog" aria-labelledby="m3208" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M3208 — Projet tutoré S3</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">—</td>
                                            <td class="td">—</td>
                                            <td class="tp">—</td>
                                            <td class="total">—</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Développer un projet technique de production multimédia et, ou internet. Mettre l’étudiant en situation d’activité de
                                    technicien supérieur en le préparant à son stage en milieu professionnel.</p>
                                    <p>Conduire en équipe un projet d’envergure professionnelle mettant en oeuvre la transversalité des connaissances
                                    techniques, technologiques et générales de la spécialité.</p>
                                    <p>Développer les compétences relationnelles de l'étudiant.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>animer une réunion, conduire un projet, construire un budget, gérer des ressources, appliquer les
                                        techniques de management, définir une stratégie de communication, travailler en équipe, formaliser un
                                        processus de gestion de projet,</li>
                                        <li>justifier une démarche ainsi que des choix esthétiques et techniques, appliquer le droit de l’information,
                                        de la propriété intellectuelle et du droit à l’image,</li>
                                        <li>s’autoformer à de nouveaux outils, logiciels, technologies, être autonome et faire preuve d’initiative,</li>
                                        <li>exploiter les compétences acquises ou en cours d'acquisition dans les autres modules,</li>
                                        <li>synthétiser l’information et la restituer sous forme écrite et/ou orale,</li>
                                        <li>mettre en oeuvre une démarche d'intelligence économique : veille, enquête de terrain (benchmarking).</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>L'ensemble des modules.</p>

                                    <h3>Contenus</h3>
                                    <p>Le projet doit avoir une envergure réaliste pour mettre en oeuvre l’ensemble des activités, des tâches et des
                                    contraintes de la conduite d’un projet industriel ou de service, à savoir :</p>
                                    <ul>
                                      <li>constitution d’une équipe ; répartition et planification des tâches ; gestion du temps et des délais ;</li>
                                      <li>utilisation d’outils de gestion de projet ;</li>
                                      <li>analyse comparative de diverses solutions techniques et technologiques ;</li>
                                      <li>rédaction documentation, mémoire, cahier des charges ;</li>
                                      <li>présentation orale soutenue par un support multimédia adapté.</li>
                                    </ul>
                                    <p>Il peut porter sur :</p>
                                    <ul>
                                      <li>la conception et développement d’un site web dynamique, d’un projet audiovisuel ou d'un produit
                                    multimédia (application mobile, visite virtuelle, installation numérique, réalité augmentée, jeu vidéo) ;</li>
                                      <li>l'organisation d’un événement ou d’une campagne de communication pluri-média.</li>
                                    </ul>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Il peut s'agir d'un nouveau projet ou de la prolongation du projet du S2. Il nécessite la constitution d’une équipe
                                    projet de 4 à 8 étudiants. L’accompagnement est assuré par l'équipe pédagogique, éventuellement complétée par
                                    un intervenant professionnel. La phase de réalisation n’est pas une fin en soi à ce stade.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Modules PPP, stage.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Développement web, programmation, production audiovisuelle, infographie, réalisation multimédia,
                                    documentation, TIC, autonomie, initiative, relation client, analyse des besoins, cahier des charges, équipe.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m4101" class="element s4 ue1 m4101 trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4101</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Anglais</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm"></td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">30</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4101" tabindex="-1" role="dialog" aria-labelledby="m4101" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4101 — Anglais S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm"></td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">30</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Savoir appliquer les compétences acquises dans les modules LCI 110, 210, 310 à la langue professionnelle et
                                    technique.</p>
                                    <p>Préparer à une certification reconnue (par exemple CLES 1, voire CLES 2…).</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>décrire et d’analyser des produits multimédias de manière professionnelle dans le cadre d’un projet personnel.</li>
                                        <li>décrire avec précision un processus lié au domaine.</li>
                                        <li>communiquer dans le cadre professionnel, participer à une réunion tout en tenant compte des spécificités
                                        culturelles et civilisationnelles des pays anglophones.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M3101.</p>

                                    <h3>Contenus</h3>
                                    <p>Description et analyse de produits de communication, expression orale et écrite sur des sujets liés à
                                    l’informatique, à l’Internet, au multimédia.</p>
                                    <p>Anglais professionnel : exposés spécifiques, négociations, communication en réunion, compte rendu de réunion,
                                    marché du travail, mercatique.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Présentations orales et écrites de sites, de publicités en langue anglaise, analyse de la partie langue dans le
                                    projet multimédia, simulations de situations, soutenance du projet tutoré en Anglais, négociations pour défendre
                                    une idée, analyse de pratiques d’entreprises à l’international.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Rédaction d’un résumé en anglais de projet ou de rapport de stage.</p>
                                    <p>Développement d’un support publicitaire répondant à un besoin identifié sur un marché étranger.</p>
                                    <p>Élaboration un dossier pour le lancement d’un produit/service à l’étranger.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Sites, cédéroms, projets, résumé en anglais, produits de communication, mercatique, CLES, réunion.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m4102C" class="element s4 ue1 m4102C esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4102C</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Esthétique et expression artistique</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4102C" tabindex="-1" role="dialog" aria-labelledby="m4102C" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4102C — Esthétique et expression artistique S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Développer le sens artistique et la créativité.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>concevoir et créer des réalisations artistiques sur écran.</li>
                                        <li>faire référence à des notions de design.</li>
                                        <li>utiliser les références culturelles pour appuyer un projet multimédia.</li>
                                        <li>élaborer les liens entre le fond et la forme.</li>
                                        <li>amener un concept à maturité.</li>
                                        <li>réaliser des mises en page ergonomiques et originales.</li>
                                        <li>argumenter un projet visuel et sonore</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>Connaître les techniques graphiques, la sémiologie de l’image, l’histoire de l’art.</p>

                                    <h3>Contenus</h3>
                                    <p>Provenance et territoire du design.</p>
                                    <p>Composition graphique.</p>
                                    <p>Ergonomie sur écran.</p>
                                    <p>Mise en page, maquettage et présentation.</p>
                                    <p>Chaîne graphique (print), vidéo, campagnes publicitaire globale, événementielle, etc.</p>
                                    <p>Communication des marques.</p>
                                    <p>Communication et culture générale artistique.</p>
                                    <p>Artistes (cinéastes, photographes, peintres, musiciens, etc.) au service des campagnes publicitaires.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>—</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Préparation aux métiers de l'internet et du multimédia.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Design, ergonomie, mise en page.</p>
                                    <p>Vidéo, créateurs et créatifs, expositions.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                              
          <a data-toggle="modal" href="#m4103C" class="element s4 ue1 m4103C com">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4103C</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Écriture pour les médias numériques</h2>
              <h3 class="cat">Communication/écriture</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4103C" tabindex="-1" role="dialog" aria-labelledby="m4103C" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4103C — Écriture pour les médias numériques S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Connaître les enjeux du web sémantique – développer une culture de l'indexation.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>connaître et mettre en oeuvre les outils sémantiques.</li>
                                        <li>faire des requêtes dans un langage structuré.</li>
                                        <li>créer une base de connaissances dans un domaine donné.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M1103 et M2105.</p>

                                    <h3>Contenus</h3>
                                    <p>Présentation du web sémantique et de ses enjeux ; présentation des outils de recherche sémantique existants ;
                                    conception d'ontologies ; utilisation des outils pour exploiter ces ontologies ; production de contenus ou indexation
                                    de documents pour le web sémantique.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>On choisira soit de mettre en avant les enjeux culturels du web sémantique, soit de privilégier des aspects plus
                                    techniques. D'un côté, connaître les outils ; de l'autre, les mettre en oeuvre.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>—</p>

                                    <h3>Mots-clés</h3>
                                    <p>Web sémantique, bases de connaissances, documentation, raisonnement, standard, ontologie, vocabulaire
                                    normé, thesaurus.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                    
          <a data-toggle="modal" href="#m4104C" class="element s4 ue1 m4104C trans">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4104C</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Environnement juridique, éco. et merca. des orga.</h2>
              <h3 class="cat">Transversal</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4104C" tabindex="-1" role="dialog" aria-labelledby="m4104C" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4104C — Environnement juridique, économique et mercatique des
                                    organisations S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>L’objectif du module est de conduire l’étudiant à acquérir les outils juridiques, comptables et financiers
                                    nécessaires au déroulement de la vie professionnelle.</p>
                                    <p>Il permet de donner aux étudiants les connaissances leur permettant de comprendre les documents comptables
                                    de base, de leur permettre de cerner les coûts d’un produit ou d’un service, de leur fournir des outils permettant
                                    de mesurer la rentabilité d’une entreprise ou d’une activité.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>qualifier un contrat de travail,</li>
                                        <li>construire un budget,</li>
                                        <li>gérer des ressources,</li>
                                        <li>comprendre les étapes de la création et de la vie d’une entreprise (notion d’entrepreneuriat).</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>M3109.</p>

                                    <h3>Contenus</h3>
                                    <p>Les relations juridiques des entreprises avec leurs salariés (le contrat de travail, le statut du salarié, la rupture du
                                    contrat de travail, les conflits individuels du travail).</p>
                                     <p>Les documents de synthèse : impact de différentes opérations commerciales sur le bilan, le compte de résultat.
                                    Calcul de coûts et analyse de rentabilité : mettre en place le calcul du coût complet et partiel simplifié d’un produit
                                    ou d’un service, déterminer une politique de prix.</p>
                                     <p>Éléments d’analyse financière : à partir des documents de synthèse, extraire les grandes masses par fonction
                                    (FRNG, BFR, trésorerie), mettre en place le calcul de ratios, élaborer une conclusion sur la santé financière d’une
                                    entreprise.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Travailler sur des contrats types CDD/CDI, à partir d’un projet de création d’entreprise, déterminer les formalités,
                                    les organismes compétents, etc.</p>
                                    <p>Aborder les techniques et principes de gestion dans le cadre d’une entreprise du domaine des nouvelles
                                    technologies, appliquer les calculs de préférence à des produits ou services du domaine de l’informatique et des
                                    nouvelles technologies.</p>
                                    <p>Le module pourra prendre appui sur une simulation de gestion (Jeu sérieux).</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>PPP.</p>

                                    <h3>Mots-clés</h3>
                                    <p>CDD, CDI, travail temporaire, rémunération, licenciement, conseil des Prud’hommes, EURL, SARL, « free
                                    lance », entreprise individuelle, protection sociale, régime fiscal, auto-entrepreneur.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div> 
          
          <a data-toggle="modal" href="#m4204" class="element s4 ue1 m4105 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4105</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Projet tutoré</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          
          <a data-toggle="modal" href="#m4205" class="element s4 ue1 m4106 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">1</span></p>
              <p class="coef">coef <span class="coefvalue">6</span></p>
              <p class="id">M4106</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Stage</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          
                    
          <a data-toggle="modal" href="#m4201C" class="element s4 ue2 m4201C info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4201C</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Développement multimédia</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4201C" tabindex="-1" role="dialog" aria-labelledby="m4201C" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4201C — Développement multimédia S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Maîtriser une technologie d'intégration multimédia.</p>
                                    <p>Savoir concevoir et réaliser des animations riches et des applications multimédia.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>appréhender les divers aspects de la production d’un programme multimédia, de la conception à la finalisation ;
                                        maîtriser l’ensemble des aspects esthétiques et techniques de la réalisation.</li>
                                        <li>créer des animations riches : gestion du son et des interactions utilisateurs sur des éléments graphiques
                                        animés.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>—</p>

                                    <h3>Contenus</h3>
                                    <p>Approfondissement d’un logiciel d’intégration multimédia, des langages de programmation associés, et de son
                                    environnement de développement.</p>
                                    <p>Savoir choisir les médias appropriés, les optimiser, en réaliser l'intégration, développer les interactions et finaliser
                                    un projet pour sa diffusion.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Réalisation d'une application multimédia en utilisant les technologies appropriées.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Réalisation d'un jeu interactif.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Production multimédia.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                    
          <a data-toggle="modal" href="#m4202C" class="element s4 ue2 m4202C esth-video">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4202C</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Infographie</h2>
              <h3 class="cat">Esth./vidéo</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4202C" tabindex="-1" role="dialog" aria-labelledby="m4202C" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4202C — Infographie S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>A l'aide d'un logiciel 3D, l'objectif est de modéliser des objets, leur appliquer une texture et un éclairage approprié
                                    pour générer une rendu. L'animation d’objets 3D est aussi abordée dans ce module.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de maîtriser les bases de la modélisation de scènes 3D et leur animation.</p>

                                    <h3>Prérequis</h3>
                                    <p>Maîtriser les notions techniques relatives à l’image numérique, infographie et animation 2D.</p>

                                    <h3>Contenus</h3>
                                    <p>Production de « contenu » 3D sous forme d’images pré-calculées ou de scènes 3D exploitables par les moteurs
                                    « temps réel ».</p>
                                    <p>Modélisation – Texture – Éclairage – Rendu – Animation.</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Travail sur machine précédé d’un travail de conception préparatoire (croquis, perspective, constructions en
                                    volume...).</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>L’autonomie acquise doit permettre d’appréhender différents logiciels utilisant les concepts 3D : logiciels de
                                    production 3D, moteurs de rendu temps réel, logiciels de post-production, 3D interactive..</p>

                                    <h3>Mots-clés</h3>
                                    <p>3D pré-calculée, 3D temps réel, animation, rendu, texture, éclairage.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                    
          <a data-toggle="modal" href="#m4203C" class="element s4 ue2 m4203C info-reseaux">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4203C</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Développement multimédia</h2>
              <h3 class="cat">Informatique/réseaux</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">10</td>
                  <td class="td">15</td>
                  <td class="tp">15</td>
                  <td class="total">40</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4203C" tabindex="-1" role="dialog" aria-labelledby="m4203C" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4203C — Intégration et gestion de contenus S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">10</td>
                                            <td class="td">15</td>
                                            <td class="tp">15</td>
                                            <td class="total">40</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Savoir configurer et utiliser un système de gestion de contenus, dans des environnements de travail collaboratifs.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>maîtriser l'ensemble de la chaîne d'intégration multimédia.</li>
                                        <li>mettre en place et utiliser des systèmes de gestion de contenus (CMS).</li>
                                        <li>concevoir et développer des gabarits et thèmes graphiques pour des CMS.</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>—</p>

                                    <h3>Contenus</h3>
                                    <p>Installer et configurer un système de gestion de contenus (CMS).</p>
                                    <p>Mettre en place l'arborescence des pages et menus, avec un système de navigation adapté.</p>
                                    <p>Alimenter le CMS en contenus textuels et multimédias.</p>
                                    <p>Créer des gabarits de page et des thèmes graphiques adaptés à un cahier des charges et respectant les
                                    contraintes de référencement, d'ergonomie et d'accessibilité.</p>
                                    <p>Installer, configurer et utiliser des modules complémentaires pour un CMS (bibliothèques d'images, cartes de
                                    localisation, commerce électronique, liens avec des réseaux sociaux).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Utilisation d'un système de gestion de contenus du domaine.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Réalisation d’un projet multimédia.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Systèmes de gestion de contenus, CMS, gestion collaborative de sites internet.</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>     
                      
          <a data-toggle="modal" href="#m4204" class="element s4 ue2 m4204 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">2</span></p>
              <p class="id">M4204</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Projet tutoré</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4204" tabindex="-1" role="dialog" aria-labelledby="m4204" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4105/M4204 — Projet tutoré S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">—</td>
                                            <td class="td"></td>
                                            <td class="tp">—</td>
                                            <td class="total">—</td>
                                        </tr>
                                        </tbody>
                                    </table>
                  <h3>Objectifs du module</h3>
                                    <p>Développer un projet technique de production multimédia et, ou internet. Mettre l’étudiant en situation d’activité de
                                    technicien supérieur en le préparant à son stage en milieu professionnel.</p>
                                    <p>Conduire en équipe un projet d’envergure professionnelle mettant en oeuvre la transversalité des connaissances
                                    techniques, technologiques et générales de la spécialité.</p>
                                    <p>Développer les compétences relationnelles de l'étudiant.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>animer une réunion, conduire un projet, construire un budget, gérer des ressources, appliquer les
                                        techniques de management, définir une stratégie de communication, travailler en équipe, formaliser un
                                        processus de gestion de projet,</li>
                                        <li>justifier une démarche ainsi que des choix esthétiques et techniques, appliquer le droit de l’information,
                                        de la propriété intellectuelle et du droit à l’image,</li>
                                        <li>s’autoformer à de nouveaux outils, logiciels, technologies, être autonome et faire preuve d’initiative,</li>
                                        <li>exploiter les compétences acquises ou en cours d'acquisition dans les autres modules,</li>
                                        <li>synthétiser l’information et la restituer sous forme écrite et/ou orale,</li>
                                        <li>mettre en oeuvre une démarche d'intelligence économique : veille, enquête de terrain (benchmarking).</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>L'ensemble des modules.</p>

                                    <h3>Contenus</h3>
                                    <p>Le projet doit avoir une envergure réaliste pour mettre en oeuvre l’ensemble des activités, des tâches et des
                                    contraintes de la conduite d’un projet industriel ou de service, à savoir :</p>
                                    <ul>
                                      <li>constitution d’une équipe ; répartition et planification des tâches ; gestion du temps et des délais ;</li>
                                      <li>utilisation d’outils de gestion de projet ;</li>
                                      <li>analyse comparative de diverses solutions techniques et technologiques ;</li>
                                      <li>rédaction documentation, mémoire, cahier des charges ;</li>
                                      <li>présentation orale soutenue par un support multimédia adapté.</li>
                                    </ul>
                                    <p>Il peut porter sur :</p>
                                    <ul>
                                      <li>la conception et développement d’un site web dynamique, d’un projet audiovisuel ou d'un produit
                                    multimédia (application mobile, visite virtuelle, installation numérique, réalité augmentée, jeu vidéo) ;</li>
                                      <li>l'organisation d’un événement ou d’une campagne de communication pluri-média.</li>
                                    </ul>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Il peut s'agir d'un nouveau projet ou de la prolongation du projet du S2. Il nécessite la constitution d’une équipe
                                    projet de 4 à 8 étudiants. L’accompagnement est assuré par l'équipe pédagogique, éventuellement complétée par
                                    un intervenant professionnel. La phase de réalisation n’est pas une fin en soi à ce stade.</p>

                                    <h3>Prolongements possibles</h3>
                                    <p>Modules PPP, stage.</p>

                                    <h3>Mots-clés</h3>
                                    <p>Développement web, programmation, production audiovisuelle, infographie, réalisation multimédia,
                                    documentation, TIC, autonomie, initiative, relation client, analyse des besoins, cahier des charges, équipe.</p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                    
          <a data-toggle="modal" href="#m4205" class="element s4 ue2 m4205 prof">
            <div class="ref">
              <p class="semestre">S <span class="semvalue">4</span></p>
              <p class="ue">UE <span class="uevalue">2</span></p>
              <p class="coef">coef <span class="coefvalue">6</span></p>
              <p class="id">M4205</p>
            </div>
            <div class="nom-modules">
              <h2 class="name">Stage</h2>
              <h3 class="cat">Professionnalisation</h3>
            </div>
            <table class="heures">
              <thead>
                <tr>
                  <th>CM</th>
                  <th>TD</th>
                  <th>TP</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="cm">—</td>
                  <td class="td">—</td>
                  <td class="tp">—</td>
                  <td class="total">—</td>
                </tr>
              </tbody>
            </table>
          </a>
          <div class="modal fade" id="m4205" tabindex="-1" role="dialog" aria-labelledby="m4205" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                    <h4 class="modal-title">M4106/M4205 — Stage S4</h4>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-striped table-bordered">
                                        <thead>
                                        <tr>
                                            <th>CM</th>
                                            <th>TD</th>
                                            <th>TP</th>
                                            <th>Total</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <tr>
                                            <td class="cm">—</td>
                                            <td class="td">—</td>
                                            <td class="tp">—</td>
                                            <td class="total">—</td>
                                        </tr>
                                        </tbody>
                                    </table>
                                    <h3>Objectifs du module</h3>
                                    <p>Découverte de l’organisation dans ses aspects sociaux, organisationnels et technico-économiques.</p>
                                    <p>Découverte de la réalité de l’activité du technicien supérieur.</p>
                                    <p>Mise en application des outils, des connaissances et savoir-faire acquis durant la formation durant la formation.</p>
                                    <p>Acquisition de savoir-faire techniques et professionnels.</p>
                                    <p>Missions : travaux d’études et, ou de réalisations au sein de l'organisation conformes à la spécialité MMI.</p>

                                    <h3>Compétences visées</h3>
                                    <p>Être capable de :</p>
                                    <ul>
                                        <li>consolider ses acquis dans les domaines de la communication, de la culture, de la connaissance de
                                        l’environnement socio-économique, et de la technologie (infographie, intégration web, développement,
                                        audiovisuel, etc.).</li>
                                        <li>développer des compétences personnelles et relationnelles : initiative, travail en équipe, autonomie…</li>
                                    </ul>

                                    <h3>Prérequis</h3>
                                    <p>Ensemble des modules.</p>

                                    <h3>Contenus</h3>
                                    <p>L’ensemble du processus stage doit se faire dans le cadre d’une démarche de type qualité, décrivant clairement
                                    les points à respecter par exemple : la recherche des stages incluant la négociation préalable des travaux
                                    d’études et de réalisation à mettre en oeuvre au cours du stage, la signature des conventions, le déroulement du
                                    stage, le suivi des stagiaires (points intermédiaires, visite), le compte rendu d’activité (rapport écrit et soutenance
                                    suivant une démarche professionnelle : la structure, la qualité de communication et l’argumentation des comptes
                                    rendus écrit et oral).</p>

                                    <h3>Modalités de mise en œuvre</h3>
                                    <p>Le processus est piloté par un responsable des stages ; il implique l’ensemble de l’équipe pédagogique pour
                                    assurer le suivi des stagiaires (lien avec les tuteurs professionnels, visite en organisations).</p>
                                    <p>Le stage est évalué conjointement par l’organisation (tuteur organisation) et le département (tuteur enseignant et
                                    jury) sur les éléments suivants :</p>
                                    <ul>
                                      <li>le travail au sein de l'organisation, au regard des objectifs fixés dans la convention,</li>
                                      <li>le rapport écrit, cadré dans sa forme, mettant en évidence les compétences mises en oeuvre au cours du stage,</li>
                                      <li>la soutenance orale par un jury mixte organisation et département.</li>
                                    </ul>
                                    <p>Pour ces 3 éléments, l’évaluation du stagiaire doit porter sur :</p>
                                    <ul>
                                      <li>sa capacité à utiliser ses acquis académiques dans la réalisation de sa mission,</li>
                                      <li>les acquis résultant de l’immersion dans le milieu professionnel : compétences techniques et compétences
                                    relationnelles en référence au référentiel d’activités et de compétences du DUT.</li>
                                    </ul>

                                    <h3>Prolongements possibles</h3>
                                    <p>Insertion professionnelle.</p>

                                    <h3>Mots-clés</h3>
                                    <p>stage, organisation, insertion, autonomie, PPP</p>

                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
                                </div>
                            </div><!-- /.modal-content -->
                        </div><!-- /.modal-dialog -->
                    </div>
                    
        </div> <!-- #container -->
        <footer>
          <p>© Ministère de l’enseignement supérieur et de la recherche, 2013<br/><a href="http://www.enseignementsup-recherche.gouv.fr">http://www.enseignementsup-recherche.gouv.fr</a></p>
        </footer>
      </div>
    </div>

    <script src="lib/bootstrap/assets/js/jquery.js"></script>
    <script src="lib/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="lib/js/application.js"></script>
    <script src="lib/js/jquery.isotope.min.js"></script>
    <script src="lib/js/fake-element.js"></script>
    <script>
    $(function(){

      var $container = $('#container'),
      filters = {};

      $container.isotope({
        itemSelector : '.element',
        layoutMode: 'cellsByRow',
          cellsByRow: {
            columnWidth: 210,
            rowHeight: 150
          },
        masonry : {
          columnWidth : 120
        },
        masonryHorizontal : {
          rowHeight: 120
        },
        cellsByColumn : {
          columnWidth : 210,
          rowHeight : 150
        },
        getSortData : {
          semvalue : function( $elem ) {
            return parseInt( $elem.find('.semvalue').text(), 10 );
          },
          uevalue : function( $elem ) {
            return parseInt( $elem.find('.uevalue').text(), 10 );
          },
          coefvalue : function( $elem ) {
            return parseInt( $elem.find('.coefvalue').text(), 10 );
          },
          cm : function( $elem ) {
            return parseInt( $elem.find('.cm').text(), 10 );
          },
          td : function( $elem ) {
            return parseInt( $elem.find('.td').text(), 10 );
          },
          tp : function( $elem ) {
            return parseInt( $elem.find('.tp').text(), 10 );
          },
          total : function( $elem ) {
            return parseInt( $elem.find('.total').text(), 10 );
          },
          name : function ( $elem ) {
            return $elem.find('.name').text();
          },
          cat : function ( $elem ) {
            return $elem.find('.cat').text();
          }
        }
      });
      
      var $optionSets = $('#options-2 .option-set'),
                $optionLinks = $optionSets.find('a');
      
            $optionLinks.click(function(){
              var $this = $(this);
              // don't proceed if already selected
              if ( $this.hasClass('selected') ) {
                return false;
              }
              var $optionSet = $this.parents('.option-set');
              $optionSet.find('.selected').removeClass('selected');
              $this.addClass('selected');
        
              // make option object dynamically, i.e. { filter: '.my-filter-class' }
              var options = {},
                  key = $optionSet.attr('data-option-key'),
                  value = $this.attr('data-option-value');
              // parse 'false' as false boolean
              value = value === 'false' ? false : value;
              options[ key ] = value;
              if ( key === 'layoutMode' && typeof changeLayoutMode === 'function' ) {
                // changes in layout modes need extra logic
                changeLayoutMode( $this, options )
              } else {
                // otherwise, apply new options
                $container.isotope( options );
              }
              
              return false;
            });
      
      // change layout
            var isHorizontal = false;
            function changeLayoutMode( $link, options ) {
              var wasHorizontal = isHorizontal;
              isHorizontal = $link.hasClass('horizontal');
      
              if ( wasHorizontal !== isHorizontal ) {
                // orientation change
                // need to do some clean up for transitions and sizes
                var style = isHorizontal ? 
                  { height: '80%', width: $container.width() } : 
                  { width: 'auto' };
                // stop any animation on container height / width
                $container.filter(':animated').stop();
                // disable transition, apply revised style
                $container.addClass('no-transition').css( style );
                setTimeout(function(){
                  $container.removeClass('no-transition').isotope( options );
                }, 100 )
              } else {
                $container.isotope( options );
              }
            }
      
      var $sortBy = $('#sort-by');
      $('#shuffle a').click(function(){
        $container.isotope('shuffle');
        $sortBy.find('.selected').removeClass('selected');
        $sortBy.find('[data-option-value="random"]').addClass('selected');
        return false;
      });

      // filter buttons
      $('.filter a').click(function(){
        var $this = $(this);
        // don't proceed if already selected
        if ( $this.hasClass('selected') ) {
          return;
        }

        var $optionSet = $this.parents('.option-set');
        // change selected class
        $optionSet.find('.selected').removeClass('selected');
        $this.addClass('selected');

        // store filter value in object
        // i.e. filters.color = 'red'
        var group = $optionSet.attr('data-filter-group');
        filters[ group ] = $this.attr('data-filter-value');
        // convert object into array
        var isoFilters = [];
        for ( var prop in filters ) {
          isoFilters.push( filters[ prop ] )
        }
        var selector = isoFilters.join('');
        $container.isotope({ filter: selector });

        return false;
      });

    });
    </script>

  </section> <!-- #content -->


</body>
</html>
  }

end