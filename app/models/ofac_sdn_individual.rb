require 'active_record'

class OfacSdnIndividual < ActiveRecord::Base

  # This code is really ugly, but given OfacIndividual.new({:name => {:first_name => 'Incredibly Long Name', :last_name => 'No Match'}}).score
  # it builds sql like this:
  #
  # if use_ors is true:
  #
  # SELECT last_name,
  #        first_name_1,
  #        first_name_2,
  #        first_name_3,
  #        first_name_4,
  #        first_name_5,
  #        first_name_6,
  #        first_name_7,
  #        first_name_8,
  #        alternate_last_name,
  #        alternate_first_name_1,
  #        alternate_first_name_2,
  #        alternate_first_name_3,
  #        alternate_first_name_4,
  #        alternate_first_name_5,
  #        alternate_first_name_6,
  #        alternate_first_name_7,
  #        alternate_first_name_8,
  #        address,
  #        city
  # FROM   "ofac_sdn_individuals"
  # WHERE  ( ( ( ( ( ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'NO'
  #                                   OR "ofac_sdn_individuals"."first_name_1" =
  #                                      'NO' )
  #                                 OR "ofac_sdn_individuals"."first_name_2" = 'NO'
  #                              )
  #                               OR "ofac_sdn_individuals"."first_name_3" = 'NO' )
  #                             OR "ofac_sdn_individuals"."first_name_4" = 'NO' )
  #                           OR "ofac_sdn_individuals"."first_name_5" = 'NO' )
  #                         OR "ofac_sdn_individuals"."first_name_6" = 'NO' )
  #                       OR "ofac_sdn_individuals"."first_name_7" = 'NO' )
  #                     OR "ofac_sdn_individuals"."first_name_8" = 'NO' )
  #                   OR ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" =
  #                                      'MATCH'
  #                                       OR "ofac_sdn_individuals"."first_name_1" =
  #                                          'MATCH'
  #                                    )
  #                                     OR "ofac_sdn_individuals"."first_name_2" =
  #                                        'MATCH'
  #                                  )
  #                                   OR "ofac_sdn_individuals"."first_name_3" =
  #                                      'MATCH' )
  #                                 OR "ofac_sdn_individuals"."first_name_4" =
  #                                    'MATCH' )
  #                               OR "ofac_sdn_individuals"."first_name_5" = 'MATCH'
  #                            )
  #                             OR "ofac_sdn_individuals"."first_name_6" = 'MATCH' )
  #                           OR "ofac_sdn_individuals"."first_name_7" = 'MATCH' )
  #                         OR "ofac_sdn_individuals"."first_name_8" = 'MATCH' ) )
  #                 OR ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" =
  #                                    'INCREDIBLY'
  #                                     OR "ofac_sdn_individuals"."first_name_1" =
  #                                        'INCREDIBLY'
  #                                  )
  #                                   OR "ofac_sdn_individuals"."first_name_2" =
  #                                      'INCREDIBLY'
  #                                )
  #                                 OR "ofac_sdn_individuals"."first_name_3" =
  #                                    'INCREDIBLY'
  #                              )
  #                               OR "ofac_sdn_individuals"."first_name_4" =
  #                                  'INCREDIBLY' )
  #                             OR "ofac_sdn_individuals"."first_name_5" =
  #                                'INCREDIBLY' )
  #                           OR "ofac_sdn_individuals"."first_name_6" =
  #                              'INCREDIBLY' )
  #                         OR "ofac_sdn_individuals"."first_name_7" = 'INCREDIBLY'
  #                      )
  #                       OR "ofac_sdn_individuals"."first_name_8" = 'INCREDIBLY' )
  #              )
  #               OR ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'LONG'
  #                                   OR "ofac_sdn_individuals"."first_name_1" =
  #                                      'LONG' )
  #                                 OR "ofac_sdn_individuals"."first_name_2" =
  #                                    'LONG' )
  #                               OR "ofac_sdn_individuals"."first_name_3" = 'LONG'
  #                            )
  #                             OR "ofac_sdn_individuals"."first_name_4" = 'LONG' )
  #                           OR "ofac_sdn_individuals"."first_name_5" = 'LONG' )
  #                         OR "ofac_sdn_individuals"."first_name_6" = 'LONG' )
  #                       OR "ofac_sdn_individuals"."first_name_7" = 'LONG' )
  #                     OR "ofac_sdn_individuals"."first_name_8" = 'LONG' ) )
  #             OR ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'NAME'
  #                                 OR "ofac_sdn_individuals"."first_name_1" =
  #                                    'NAME' )
  #                               OR "ofac_sdn_individuals"."first_name_2" = 'NAME'
  #                            )
  #                             OR "ofac_sdn_individuals"."first_name_3" = 'NAME' )
  #                           OR "ofac_sdn_individuals"."first_name_4" = 'NAME' )
  #                         OR "ofac_sdn_individuals"."first_name_5" = 'NAME' )
  #                       OR "ofac_sdn_individuals"."first_name_6" = 'NAME' )
  #                     OR "ofac_sdn_individuals"."first_name_7" = 'NAME' )
  #                   OR "ofac_sdn_individuals"."first_name_8" = 'NAME' ) )
  #           OR (( ( ( ( ( ( ( ( ( ( ( (
  #                             "ofac_sdn_individuals"."alternate_last_name" =
  #                             'NO'
  #                              OR
  #                                 "ofac_sdn_individuals"."alternate_first_name_1"
  #                                 =
  #                                 'NO'
  #                                  )
  #                                      OR
  #                               "ofac_sdn_individuals"."alternate_first_name_2"
  #                               =
  #                               'NO'
  #                                        )
  #                                    OR
  #                             "ofac_sdn_individuals"."alternate_first_name_3" =
  #                             'NO'
  #                                     )
  #                                  OR
  #                           "ofac_sdn_individuals"."alternate_first_name_4" =
  #                           'NO' )
  #                                OR
  #                         "ofac_sdn_individuals"."alternate_first_name_5" =
  #                         'NO'
  #                             )
  #                              OR "ofac_sdn_individuals"."alternate_first_name_6"
  #                                 = 'NO'
  #                           )
  #                            OR "ofac_sdn_individuals"."alternate_first_name_7" =
  #                               'NO' )
  #                          OR "ofac_sdn_individuals"."alternate_first_name_8" =
  #                             'NO' )
  #                        OR ( ( ( ( ( ( ( (
  #                                 "ofac_sdn_individuals"."alternate_last_name"
  #                                 =
  #                                 'MATCH'
  #                                  OR
  # "ofac_sdn_individuals"."alternate_first_name_1"
  # =
  # 'MATCH' )
  #      OR
  # "ofac_sdn_individuals"."alternate_first_name_2" =
  # 'MATCH'
  #   )
  #    OR
  # "ofac_sdn_individuals"."alternate_first_name_3"
  # =
  # 'MATCH'
  # )
  #  OR "ofac_sdn_individuals"."alternate_first_name_4"
  #     =
  #     'MATCH'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_5" =
  #   'MATCH'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_6" =
  # 'MATCH'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_7" =
  # 'MATCH' )
  # OR "ofac_sdn_individuals"."alternate_first_name_8" =
  # 'MATCH'
  # ) )
  # OR ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name" =
  #     'INCREDIBLY'
  #      OR
  # "ofac_sdn_individuals"."alternate_first_name_1" =
  # 'INCREDIBLY'
  # )
  #    OR
  # "ofac_sdn_individuals"."alternate_first_name_2"
  # =
  # 'INCREDIBLY'
  #     )
  #  OR "ofac_sdn_individuals"."alternate_first_name_3"
  #     =
  #     'INCREDIBLY' )
  # OR "ofac_sdn_individuals"."alternate_first_name_4" =
  #   'INCREDIBLY'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_5" =
  # 'INCREDIBLY'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_6" =
  # 'INCREDIBLY'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_7" =
  # 'INCREDIBLY'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_8" =
  # 'INCREDIBLY'
  # )
  # )
  # OR ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name" =
  #   'LONG'
  #    OR
  # "ofac_sdn_individuals"."alternate_first_name_1"
  # =
  # 'LONG'
  # )
  #  OR "ofac_sdn_individuals"."alternate_first_name_2"
  #     =
  #     'LONG'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_3" =
  #   'LONG'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_4" =
  # 'LONG'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_5" =
  # 'LONG' )
  # OR "ofac_sdn_individuals"."alternate_first_name_6" =
  # 'LONG'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_7" = 'LONG'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_8" = 'LONG' )
  # )
  # OR ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name" =
  # 'NAME'
  #  OR "ofac_sdn_individuals"."alternate_first_name_1"
  #     =
  #     'NAME'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_2" =
  #   'NAME'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_3" =
  # 'NAME'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_4" =
  # 'NAME' )
  # OR "ofac_sdn_individuals"."alternate_first_name_5" =
  # 'NAME'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_6" = 'NAME'
  # )
  # OR "ofac_sdn_individuals"."alternate_first_name_7" = 'NAME' )
  # OR "ofac_sdn_individuals"."alternate_first_name_8" = 'NAME' ) )) )
  #
  #
  #
  #
  #
  #
  # if use_ors is false, when you call db_hit?  OfacIndividual.new({:name => {:first_name => 'Incredibly Long Name', :last_name => 'No Match'}}).db_hit?
  #
  # SELECT 1 AS one
  # FROM   "ofac_sdn_individuals"
  # WHERE  ( ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'NO'
  #                           OR "ofac_sdn_individuals"."first_name_1" = 'NO' )
  #                         OR "ofac_sdn_individuals"."first_name_2" = 'NO' )
  #                       OR "ofac_sdn_individuals"."first_name_3" = 'NO' )
  #                     OR "ofac_sdn_individuals"."first_name_4" = 'NO' )
  #                   OR "ofac_sdn_individuals"."first_name_5" = 'NO' )
  #                 OR "ofac_sdn_individuals"."first_name_6" = 'NO' )
  #               OR "ofac_sdn_individuals"."first_name_7" = 'NO' )
  #             OR "ofac_sdn_individuals"."first_name_8" = 'NO' )
  #      AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'MATCH'
  #                           OR "ofac_sdn_individuals"."first_name_1" = 'MATCH'
  #                        )
  #                         OR "ofac_sdn_individuals"."first_name_2" = 'MATCH' )
  #                       OR "ofac_sdn_individuals"."first_name_3" = 'MATCH' )
  #                     OR "ofac_sdn_individuals"."first_name_4" = 'MATCH' )
  #                   OR "ofac_sdn_individuals"."first_name_5" = 'MATCH' )
  #                 OR "ofac_sdn_individuals"."first_name_6" = 'MATCH' )
  #               OR "ofac_sdn_individuals"."first_name_7" = 'MATCH' )
  #             OR "ofac_sdn_individuals"."first_name_8" = 'MATCH' )
  #      AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'INCREDIBLY'
  #                           OR "ofac_sdn_individuals"."first_name_1" =
  #                              'INCREDIBLY' )
  #                         OR "ofac_sdn_individuals"."first_name_2" =
  #                            'INCREDIBLY' )
  #                       OR "ofac_sdn_individuals"."first_name_3" =
  #                          'INCREDIBLY' )
  #                     OR "ofac_sdn_individuals"."first_name_4" = 'INCREDIBLY'
  #                  )
  #                   OR "ofac_sdn_individuals"."first_name_5" = 'INCREDIBLY' )
  #                 OR "ofac_sdn_individuals"."first_name_6" = 'INCREDIBLY' )
  #               OR "ofac_sdn_individuals"."first_name_7" = 'INCREDIBLY' )
  #             OR "ofac_sdn_individuals"."first_name_8" = 'INCREDIBLY' )
  #      AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'LONG'
  #                           OR "ofac_sdn_individuals"."first_name_1" = 'LONG'
  #                        )
  #                         OR "ofac_sdn_individuals"."first_name_2" = 'LONG' )
  #                       OR "ofac_sdn_individuals"."first_name_3" = 'LONG' )
  #                     OR "ofac_sdn_individuals"."first_name_4" = 'LONG' )
  #                   OR "ofac_sdn_individuals"."first_name_5" = 'LONG' )
  #                 OR "ofac_sdn_individuals"."first_name_6" = 'LONG' )
  #               OR "ofac_sdn_individuals"."first_name_7" = 'LONG' )
  #             OR "ofac_sdn_individuals"."first_name_8" = 'LONG' )
  #      AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."last_name" = 'NAME'
  #                           OR "ofac_sdn_individuals"."first_name_1" = 'NAME'
  #                        )
  #                         OR "ofac_sdn_individuals"."first_name_2" = 'NAME' )
  #                       OR "ofac_sdn_individuals"."first_name_3" = 'NAME' )
  #                     OR "ofac_sdn_individuals"."first_name_4" = 'NAME' )
  #                   OR "ofac_sdn_individuals"."first_name_5" = 'NAME' )
  #                 OR "ofac_sdn_individuals"."first_name_6" = 'NAME' )
  #               OR "ofac_sdn_individuals"."first_name_7" = 'NAME' )
  #             OR "ofac_sdn_individuals"."first_name_8" = 'NAME' )
  #       OR ( ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name" =
  #                            'NO'
  #                             OR
  #                      "ofac_sdn_individuals"."alternate_first_name_1" =
  #                      'NO'
  #                          )
  #                           OR "ofac_sdn_individuals"."alternate_first_name_2"
  #                              = 'NO'
  #                        )
  #                         OR "ofac_sdn_individuals"."alternate_first_name_3" =
  #                            'NO' )
  #                       OR "ofac_sdn_individuals"."alternate_first_name_4" =
  #                          'NO' )
  #                     OR "ofac_sdn_individuals"."alternate_first_name_5" =
  #                        'NO' )
  #                   OR "ofac_sdn_individuals"."alternate_first_name_6" = 'NO'
  #                )
  #                 OR "ofac_sdn_individuals"."alternate_first_name_7" = 'NO' )
  #               OR "ofac_sdn_individuals"."alternate_first_name_8" = 'NO' )
  #            AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name"
  #                                =
  #                                'MATCH'
  #                                 OR
  #                          "ofac_sdn_individuals"."alternate_first_name_1"
  #                          =
  #                          'MATCH' )
  #                               OR
  #                        "ofac_sdn_individuals"."alternate_first_name_2" =
  #                        'MATCH'
  #                            )
  #                             OR
  #                      "ofac_sdn_individuals"."alternate_first_name_3" =
  #                      'MATCH'
  #                          )
  #                           OR "ofac_sdn_individuals"."alternate_first_name_4"
  #                              =
  #                              'MATCH' )
  #                         OR "ofac_sdn_individuals"."alternate_first_name_5" =
  #                            'MATCH'
  #                      )
  #                       OR "ofac_sdn_individuals"."alternate_first_name_6" =
  #                          'MATCH'
  #                    )
  #                     OR "ofac_sdn_individuals"."alternate_first_name_7" =
  #                        'MATCH' )
  #                   OR "ofac_sdn_individuals"."alternate_first_name_8" =
  #                      'MATCH' )
  #            AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name"
  #                                =
  #                                'INCREDIBLY'
  #                                 OR
  #                          "ofac_sdn_individuals"."alternate_first_name_1"
  #                          =
  #                          'INCREDIBLY'
  #                          )
  #                               OR
  #                        "ofac_sdn_individuals"."alternate_first_name_2" =
  #                        'INCREDIBLY'
  #                                )
  #                             OR
  #                      "ofac_sdn_individuals"."alternate_first_name_3" =
  #                      'INCREDIBLY' )
  #                           OR "ofac_sdn_individuals"."alternate_first_name_4"
  #                              =
  #                              'INCREDIBLY'
  #                        )
  #                         OR "ofac_sdn_individuals"."alternate_first_name_5" =
  #                            'INCREDIBLY'
  #                      )
  #                       OR "ofac_sdn_individuals"."alternate_first_name_6" =
  #                          'INCREDIBLY' )
  #                     OR "ofac_sdn_individuals"."alternate_first_name_7" =
  #                        'INCREDIBLY'
  #                  )
  #                   OR "ofac_sdn_individuals"."alternate_first_name_8" =
  #                      'INCREDIBLY'
  #                )
  #            AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name"
  #                                =
  #                                'LONG'
  #                                 OR
  #                          "ofac_sdn_individuals"."alternate_first_name_1"
  #                          =
  #                          'LONG'
  #                              )
  #                               OR
  #                        "ofac_sdn_individuals"."alternate_first_name_2" =
  #                        'LONG'
  #                            )
  #                             OR
  #                      "ofac_sdn_individuals"."alternate_first_name_3" =
  #                      'LONG' )
  #                           OR "ofac_sdn_individuals"."alternate_first_name_4"
  #                              =
  #                              'LONG'
  #                        )
  #                         OR "ofac_sdn_individuals"."alternate_first_name_5" =
  #                            'LONG'
  #                      )
  #                       OR "ofac_sdn_individuals"."alternate_first_name_6" =
  #                          'LONG' )
  #                     OR "ofac_sdn_individuals"."alternate_first_name_7" =
  #                        'LONG' )
  #                   OR "ofac_sdn_individuals"."alternate_first_name_8" =
  #                      'LONG' )
  #            AND ( ( ( ( ( ( ( ( "ofac_sdn_individuals"."alternate_last_name"
  #                                =
  #                                'NAME'
  #                                 OR
  #                          "ofac_sdn_individuals"."alternate_first_name_1"
  #                          =
  #                          'NAME'
  #                              )
  #                               OR
  #                        "ofac_sdn_individuals"."alternate_first_name_2" =
  #                        'NAME'
  #                            )
  #                             OR
  #                      "ofac_sdn_individuals"."alternate_first_name_3" =
  #                      'NAME' )
  #                           OR "ofac_sdn_individuals"."alternate_first_name_4"
  #                              =
  #                              'NAME'
  #                        )
  #                         OR "ofac_sdn_individuals"."alternate_first_name_5" =
  #                            'NAME'
  #                      )
  #                       OR "ofac_sdn_individuals"."alternate_first_name_6" =
  #                          'NAME' )
  #                     OR "ofac_sdn_individuals"."alternate_first_name_7" =
  #                        'NAME' )
  #                   OR "ofac_sdn_individuals"."alternate_first_name_8" =
  #                      'NAME' ) ) )

  def self.possible_sdns(name_array, use_ors = false)
    ofac_sdn_individual = OfacSdnIndividual.arel_table

    main_conditions = nil
    alt_conditions = nil
    name_array.each do |name|
      last_name = ofac_sdn_individual[:last_name].eq(name)
      alternate_last_name = ofac_sdn_individual[:alternate_last_name].eq(name)
      first_name_1 = ofac_sdn_individual[:first_name_1].eq(name)
      first_name_2 = ofac_sdn_individual[:first_name_2].eq(name)
      first_name_3 = ofac_sdn_individual[:first_name_3].eq(name)
      first_name_4 = ofac_sdn_individual[:first_name_4].eq(name)
      first_name_5 = ofac_sdn_individual[:first_name_5].eq(name)
      first_name_6 = ofac_sdn_individual[:first_name_6].eq(name)
      first_name_7 = ofac_sdn_individual[:first_name_7].eq(name)
      first_name_8 = ofac_sdn_individual[:first_name_8].eq(name)
      alternate_first_name_1 = ofac_sdn_individual[:alternate_first_name_1].eq(name)
      alternate_first_name_2 = ofac_sdn_individual[:alternate_first_name_2].eq(name)
      alternate_first_name_3 = ofac_sdn_individual[:alternate_first_name_3].eq(name)
      alternate_first_name_4 = ofac_sdn_individual[:alternate_first_name_4].eq(name)
      alternate_first_name_5 = ofac_sdn_individual[:alternate_first_name_5].eq(name)
      alternate_first_name_6 = ofac_sdn_individual[:alternate_first_name_6].eq(name)
      alternate_first_name_7 = ofac_sdn_individual[:alternate_first_name_7].eq(name)
      alternate_first_name_8 = ofac_sdn_individual[:alternate_first_name_8].eq(name)
      if use_ors
        if main_conditions
          main_conditions = main_conditions.or(last_name.or(first_name_1).or(first_name_2).or(first_name_3).or(first_name_4).or(first_name_5).or(first_name_6).or(first_name_7).or(first_name_8))
          alt_conditions = alt_conditions.or(alternate_last_name.or(alternate_first_name_1).or(alternate_first_name_2).or(alternate_first_name_3).or(alternate_first_name_4).or(alternate_first_name_5).or(alternate_first_name_6).or(alternate_first_name_7).or(alternate_first_name_8))
        else
          main_conditions = last_name.or(first_name_1).or(first_name_2).or(first_name_3).or(first_name_4).or(first_name_5).or(first_name_6).or(first_name_7).or(first_name_8)
          alt_conditions = alternate_last_name.or(alternate_first_name_1).or(alternate_first_name_2).or(alternate_first_name_3).or(alternate_first_name_4).or(alternate_first_name_5).or(alternate_first_name_6).or(alternate_first_name_7).or(alternate_first_name_8)
        end
      else
        if main_conditions
          main_conditions = main_conditions.and(last_name.or(first_name_1).or(first_name_2).or(first_name_3).or(first_name_4).or(first_name_5).or(first_name_6).or(first_name_7).or(first_name_8))
          alt_conditions = alt_conditions.and(alternate_last_name.or(alternate_first_name_1).or(alternate_first_name_2).or(alternate_first_name_3).or(alternate_first_name_4).or(alternate_first_name_5).or(alternate_first_name_6).or(alternate_first_name_7).or(alternate_first_name_8))
        else
          main_conditions = last_name.or(first_name_1).or(first_name_2).or(first_name_3).or(first_name_4).or(first_name_5).or(first_name_6).or(first_name_7).or(first_name_8)
          alt_conditions = alternate_last_name.or(alternate_first_name_1).or(alternate_first_name_2).or(alternate_first_name_3).or(alternate_first_name_4).or(alternate_first_name_5).or(alternate_first_name_6).or(alternate_first_name_7).or(alternate_first_name_8)
        end
      end
    end

    select('last_name, first_name_1, first_name_2, first_name_3, first_name_4, first_name_5, first_name_6, first_name_7, first_name_8, alternate_last_name, alternate_first_name_1, alternate_first_name_2, alternate_first_name_3, alternate_first_name_4, alternate_first_name_5, alternate_first_name_6, alternate_first_name_7, alternate_first_name_8, address, city').
        where("#{main_conditions.to_sql} or (#{alt_conditions.to_sql})")
  end

  def name
    "#{last_name}, #{first_name_1} #{first_name_2} #{first_name_3} #{first_name_4} #{first_name_5} #{first_name_6} #{first_name_7} #{first_name_8}".strip
  end

  def alternate_identity_name
    "#{alternate_last_name}, #{alternate_first_name_1} #{alternate_first_name_2} #{alternate_first_name_3} #{alternate_first_name_4} #{alternate_first_name_5} #{alternate_first_name_6} #{alternate_first_name_7} #{alternate_first_name_8}".strip
  end
end