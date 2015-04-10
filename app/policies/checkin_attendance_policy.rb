class CheckinAttendancePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope, :context)
  end

  attr_accessor :family

  def initialize(user, record, context = {})
    super
    @room_management_on = Company::OrganizationApplication.current.has_module?("mod_checkin_room_manage_on")
    @additional_leaders = {}
    @departing_leaders = {}
    @family = user

    populate_additional_leaders
  end

  def allow_checkin?
    # user = family being checked in (array)
    # record = current setup object
    # context[:status] =  action to take with individual add/delete
    allow_all = true

    family.each do |member|
      unless member.checkin_action == :delete # delete is always allowed, don't bother checking
        occurrence = member.events.first
        is_leader = begin
                      @additional_leaders[occurrence.id].include?(member)
                    rescue
                      false
                    end

        if Church::EventAttendee.has_individual_attendance?(member, occurrence.to_time)
          member.checkin_failure_type = :already_checked_in
          allow_all = false
        elsif event_full?(occurrence.event)
          member.checkin_failure_type = :event_full
          allow_all = false
        elsif ! is_leader
          if ratio_exceeded?(occurrence)
            member.checkin_failure_type = :ratio_hold
            allow_all = false
          end
        end
      end
    end

    allow_all
  end

  private

    def event_full?(event)
      @room_management_on ? event.full? : false
    end

    def ratio_exceeded?(occurrence)
      event = occurrence.event
      attendance = Church::EventAttendee.for_occurrence(event.id, occurrence.to_time)
      @room_management_on && event.room_ratio > 0 ?
        (leader_count(occurrence) > 0 ? ((attendance.size / leader_count(occurrence)) - 1) >= event.room_ratio : true) :
        false
    end

    def leader_count(occurrence)
      attendance = Church::EventAttendee.for_occurrence(occurrence.id, occurrence.to_time)
      count = attendance.select {|att| occurrence.event.group.leader?(att.individual)}.size
      count + (additional_leader_count(occurrence) - departing_leader_count(occurrence))
    end

    def populate_additional_leaders
      family.each do |member|
        occurrence = member.events.first
        is_leader = occurrence.event.group.leader?(member)
        if member.checkin_action == :add
          add_additional_leader(occurrence.event, member) if is_leader
        elsif member.checkin_action == :delete
          if family.find(event_id: occurrence.id, individual_id: member.id, status: :add).size == 0
            add_departing_leader(occurrence.event, member) if is_leader
          end
        end
      end
    end

    def add_additional_leader(event, individual)
      unless @additional_leaders.keys.include?(event.id)
        @additional_leaders[event.id] = Set.new
      end

      @additional_leaders[event.id].add(individual)
    end

    def add_departing_leader(event, individual)
      unless @departing_leaders.keys.include?(event.id)
        @departing_leaders[event.id] = Set.new
      end

      @departing_leaders[event.id].add(individual)
    end

    def additional_leader_count(event)
      begin
        @additional_leaders[event.id].size
      rescue
        0
      end
    end

    def departing_leader_count(event)
      begin
        @departing_leaders[event.id].size
      rescue
        0
      end
    end
end

